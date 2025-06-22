import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconicpay/main.dart';
import 'Symbol.dart';
import 'Const.dart';
import 'Word.dart';


class Info extends UpdatableWidget {
  const Info({Key? key}) : super(key: key);

  @override
  State<Info> createState() => Info_Rayout();
}

class Info_Rayout extends UpdatableState<Info>{
  double _XYM =0.0;
  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
    if(MyAc?.Address != null){
      GetXYM();
    }
  }

  Future<void> GetXYM() async{
    _XYM = await setXYM(MyAc!.Address);
    if(mounted){
      setState(() {
      });
    }
  }

  void Setlang(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: MyAc?.Address !=null ?
          Container(
            height: 300,
            margin: EdgeInsets.all(15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(10),
            ),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Account',
                  style: const TextStyle(
                    fontSize: 36.0,
                  ),
                ),
                const Padding(padding: EdgeInsets.all(20)),
                Row(
                  children: <Widget>[
                    Text(
                      Name(langint()),
                      style: const TextStyle(
                        fontSize: 26.0,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Text(
                      MyAc!.AccountName,
                      style: const TextStyle(
                        fontSize: 26.0,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Text(
                        'Address:',
                        style: const TextStyle(
                          fontSize: 26.0,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(10)),
                      Expanded(
                        child: Text(
                          MyAc!.Address,
                          style: const TextStyle(fontSize: 24),
                          overflow: TextOverflow.ellipsis, // 長いテキストを省略
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: MyAc!.Address));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Text Copied")),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                Row(
                  children: <Widget>[
                    const Text(
                      'XYM:',
                      style: const TextStyle(
                        fontSize: 26.0,
                      ),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    Text(
                      '${_XYM.toStringAsFixed(3)} XYM',
                      style: const TextStyle(
                        fontSize: 26.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
              :Container(
              margin: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                Error_Info(langint()),
                style: const TextStyle(
                  fontSize: 32.0,
                ),
              )
          )
        ),
    );
  }
}