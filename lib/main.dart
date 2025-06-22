import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Websocket.dart';
import 'Symbol.dart';
import 'Word.dart';
import 'Page1.dart';
import 'Page2.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,

  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const I_Pay());
}

class I_Pay extends StatelessWidget {
  const I_Pay({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Symbol_Iconic Pay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const Iconic(title: 'Symbol_Iconoic_Pay'),
    );
  }
}

class Iconic extends StatefulWidget {
  const Iconic({super.key, required this.title});
  final String title;

  @override
  State<Iconic> createState() => Iconic_Rayout();
}

abstract class UpdatableWidget extends StatefulWidget {
  const UpdatableWidget({Key? key}) : super(key: key);

}

abstract class UpdatableState<T extends UpdatableWidget> extends State<T> {
  void updateState() {
    setState(() {
      lang = lang;
    });
  }
}

class Iconic_Rayout extends State<Iconic>{

  final GlobalKey<Pay_Rayout> _payKey = GlobalKey<Pay_Rayout>();
  final GlobalKey<Info_Rayout> _infoKey = GlobalKey<Info_Rayout>();

  late final _screens = [
    IPay(key: _payKey),
    Info(key: _infoKey),
  ];

  late final _keyList = [
    _payKey,
    _infoKey,
  ];

  int _selectedIndex = 0;

  static Iconic_Rayout of(BuildContext context) {
    final state = context.findAncestorStateOfType<Iconic_Rayout>();
    if (state == null) {
      throw FlutterError(
          'Iconic_Rayout.of() called with a context that does not contain a _Iconic_RayoutState.');
    }
    return state;
  }

  void _ChangeScreen(){
    setState(() {
      if(_selectedIndex ==0){
        _selectedIndex = 1;
      }else if(_selectedIndex ==1){
        _selectedIndex = 0;
      }
    });
  }


  @override
  initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.initState();
    setNode();
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
  @override
  Widget build(BuildContext context){
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  child: ListTile(
                    leading: Icon(Icons.language),
                    title: Text(Language(langint())),
                    trailing: Switch(
                      value: lang,
                      onChanged: (bool value) {
                        setState(() {
                          lang = value;
                          final key_now = _keyList[_selectedIndex];
                          if(key_now.currentState is UpdatableState){
                            (key_now.currentState as UpdatableState).updateState();
                          }
                        });
                      },
                    ),
                  )
              ),
              const Padding(padding: EdgeInsets.all(40)),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    (_selectedIndex == 0)
                        ? TextButton(
                      onPressed: () {
                        _ChangeScreen();
                      },
                      child: const Text(
                        'INFO',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    )
                        : TextButton(
                      onPressed: () {
                        _ChangeScreen();
                      },
                      child: const Text(
                        'Pay',
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    )
                  ]
              ),
            ],
          )
      ),
    );
  }
}

