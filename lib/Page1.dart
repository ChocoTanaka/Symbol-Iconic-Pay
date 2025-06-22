import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconicpay/main.dart';
import 'Symbol.dart';
import 'Websocket.dart';
import 'Word.dart';
import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';
import 'Const.dart';

class IPay extends UpdatableWidget {
  const IPay({Key? key}) : super(key: key);

  @override
  State<IPay> createState() => Pay_Rayout();
}

class Pay_Rayout extends UpdatableState<IPay> {

  Future readNfc(BuildContext context, int _case) async {
    int ErrorEnd = 0;
    final bool isNfcAvailable = await NfcManager.instance.isAvailable();
    if (!isNfcAvailable) {
      print('NFC is not available on this device');
    } else {
      print('NFC is available on this device');
      setState(() {
        Dialogue = ScanNFC(langint());
      });
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          Ndef? ndef = Ndef.from(tag);
          if (ndef == null) {
            print('Tag is not ndef');
            setState(() {
              Dialogue = "Read only NDEF";
            });
            await Future.delayed(Duration(seconds: 3)).then((_) {
              setState(() {
                Dialogue = "";
              });
            });
            return;
          }
          NdefMessage message = await ndef.read();
          List<NdefRecord> records = message.records;
          String str = '';
          //解錠
          //dataを取り出す
          for (NdefRecord record in records) {
            Uint8List payload = record.payload.sublist(3);
            str += utf8.decode(payload);
          }
          Account Ac = Account.fromJson(jsonDecode(str));
          //uniqueidentifierを取得する
          var identifier = tag.data["nfca"]["identifier"] as List<int>;
          String uid = identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
          NfcManager.instance.stopSession();
          String? pass = await _showPasscodeDialog(context,ErrorEnd);
          if(ErrorEnd ==0){
            switch(_case){
              case 0:
                try{
                  Ac.ReturnAccount(pass!, uid);
                  MyAc = Ac;
                  await socket_connect();
                  //正常に終わった場合
                  setState(() {
                    Dialogue = "Compleated.";
                  });
                }catch(e){
                  print(e);
                  setState(() {
                    Dialogue = "Wrong password.";
                  });
                }
                break;
                //Tx
              case 1:
                try{
                  Ac.ReturnAccount(pass!, uid);
                }catch(e){
                  print(e);
                  setState(() {
                    Dialogue = "Wrong password.";
                  });
                  break;
                }
                double senderXYM = await setXYM(Ac.Address);
                if(senderXYM < fee){
                  Alert_shortage(context, Shortage_title(langint()));
                }
                else{
                  Alert_pay(context, Pay_title(langint()), senderXYM, fee, Ac);
                }
                break;
            }
            await Future.delayed(Duration(seconds: 6)).then((_) {
              setState(() {
                Dialogue = "";
              });
            });
          }
          else{
            setState(() {
              Dialogue = "Error.";
            });
            await Future.delayed(Duration(seconds: 3)).then((_) {
              setState(() {
                Dialogue = "";
              });
            });
          }
          NfcManager.instance.stopSession();
        },
        onError: (dynamic error) {
          print(error.message);
          return Future.value();
        },
      );
    }
  }
  Future<String?> _showPasscodeDialog(BuildContext context,int ErrorEnd) async {
    return showDialog<String>(
      context: context,
      builder: (context) {
        return passAlert(context, ErrorEnd);
      },
    );
  }

  void Alert_shortage(BuildContext context , String title){
    showDialog(context: context, builder: (BuildContext context){
      return AlertDialog(
          title:Text(title),
          actions: <Widget>[
            GestureDetector(
              child: const Text(
                "OK",
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () {
                setState(() {
                  Reset();
                });
                Navigator.pop(context);
              },
            ),
          ]
      );
    },
    );
  }

  void Alert_pay(BuildContext context , String title, double amountXYM, double fee, Account Ac) {
    showDialog(context: context, builder: (BuildContext context){
      double left = amountXYM - fee;
      return AlertDialog(
          insetPadding: EdgeInsets.all(10),
          title:Text(title),
          content:Container(
            height: 200,
            child: Column(
                children: <Widget>[
                  const Text(
                    "XYM:",
                    style: const TextStyle(
                      fontSize: 32.0,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                  Text(amountXYM.toStringAsFixed(3),
                    style: const TextStyle(
                      fontSize: 24.0,
                    ),
                  ),
                  const Text(
                    "->",
                    style: const TextStyle(
                      fontSize: 28.0,
                    ),
                  ),
                  Text(left.toStringAsFixed(3),
                    style: const TextStyle(
                      fontSize: 24.0,
                    ),
                  )
                ]
            ),
          ),
          actions: <Widget>[
            GestureDetector(
              child: const Text(
                "OK",
                style: const TextStyle(fontSize: 18),
              ),
              onTap: () async{
                String message = await Tx_Send(Ac, fee, _usage);
                print(message);
                setState(() {
                  Dialogue = message;
                  Reset();
                });
                Navigator.pop(context);
              },
            ),
          ]
      );
    },
    );
  }

  AlertDialog passAlert(BuildContext context, int ErrorEnd){
    String _status = Enter_pass(langint());
    int Retry = 0;
    String _passcode = "";
    TextEditingController passcodeController = TextEditingController();
    return AlertDialog(
      title: Text(_status),
      content: TextField(
        controller: passcodeController,
        keyboardType: TextInputType.number,
        obscureText: true,
        decoration: const InputDecoration(hintText: "8桁のパスコード"),
        onChanged: (text)=> setState(() {
          _passcode =passcodeController.text;
        }),
      ),
      actions: <Widget>[
        GestureDetector(
          child: Text(
            "Cancel",
            style: const TextStyle(fontSize: 18),
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        Padding(padding: const EdgeInsets.all(5.0)),
        GestureDetector(
          onTap: () {
            if (_passcode.length != 8) {
              setState(() {
                int rest = 3-Retry;
                _status = Pass_Error_length(langint(), rest);
                Retry++;
              });
              if(Retry>=3){
                ErrorEnd = 1;
                Navigator.pop(context);
              }
            } else {
              Navigator.pop(context,_passcode);
            }
          },
          child: Text(
            "OK",
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ],
    );
  }

  Future<void> _showDialogAfterDelay() async {
    await Future.delayed(Duration.zero); // ウィジェットが初期化された後に非同期でダイアログを表示するための遅延
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Connection error"),
          content: Text(SetNode(langint())),
          actions: <Widget>[
            GestureDetector(
              child: const Text('OK'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void Reset(){
    fee = 0;
    _usage = "";
    myController1.text = "";
    myController2.text = "";
  }
  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
    setNode();
    Reset();
  }
  void Setlang(){
    setState(() {

    });
  }

  Future<void> setNode() async{
    await setNode_Test();
    if(mounted){
      setState(() {
      });
    }
    if(MyNode.endpoint.isEmpty){
      _showDialogAfterDelay();
    }
  }

  final myController1 = TextEditingController();
  final myController2 = TextEditingController();
  late double fee = 0;
  late String _usage = "";
  late String Dialogue = "";
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(
              height:20,
              child: Row(
                  children: <Widget>[
                    const Text("Node:"),
                    Text(MyNode.endpoint.isNotEmpty ? "Node Connected" : "No Connection"),
                  ]
              ),
            ),
            (Dialogue !="")?
            SizedBox(
              height: 50,
              child: Text(
                  style: const TextStyle(
                    fontSize: 25,
                    color: Colors.lightGreen,
                  ),
                  Dialogue
              ),
            ) :
            const SizedBox(
              height: 50,
            ),
            Row(
              children: <Widget>[
                const Text(
                    style: const TextStyle(fontSize: 18),
                    "Your Card:"
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Expanded(
                  child: SizedBox(
                    width: 250,
                    child: Text(
                      MyAc?.Address != null ? MyAc!.Address : "",
                      style: const TextStyle(fontSize: 18),
                      overflow: TextOverflow.ellipsis, // 長いテキストを省略
                    ),
                  ),
                ),
                const Padding(padding: EdgeInsets.all(20)),
                ElevatedButton(
                    onPressed: ()async{
                      await readNfc(context, 0);
                      setState(() {
                      });
                    },
                    child: Text(Resister(langint()))
                )
              ],
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:<Widget>[
                  Flexible(
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: TextField(
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.top,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d*)?')),
                        ],
                        controller: myController1,
                        onChanged: (text) => setState(() {
                          fee = double.tryParse(myController1.text)!;
                        }),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '000.00',
                        ),
                        style: const TextStyle(
                          fontSize: 28.0,
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(20)),
                  const Text(
                    'XYM',
                    style: TextStyle(
                      fontSize: 28,
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(10)),
                ]
            ),
            Row(
              children: <Widget>[
                Text(
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                    Usage(langint())
                ),
                const Padding(padding: EdgeInsets.all(10)),
                Flexible(
                  child: Container(
                    height: 30,
                    alignment: Alignment.center,
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      controller: myController2,
                      onChanged: (text) => setState(() {
                        _usage = myController2.text;
                      }),
                      style: const TextStyle(
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(10)),
            Row(
              mainAxisAlignment:  MainAxisAlignment.center,
              children: <Widget>[
                if (MyAc?.Address != null && fee !=0)
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[200],
                        side: BorderSide(
                          color: Colors.black,
                          width: 3,
                        ),
                      ),
                      onPressed: ()async{
                        await readNfc(context, 1);
                        setState(() {
                        });
                      },
                      child: Container(
                        width: 120,
                        height: 80,
                        alignment: Alignment.center,
                        child: Text(
                          Pay(langint()),
                          style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}