import 'dart:async';
import 'dart:convert';
import 'package:symbol_sdk/index.dart';
import 'package:symbol_sdk/symbol/index.dart';
import 'package:symbol_sdk/CryptoTypes.dart' as ct;
import 'Const.dart';
import 'Word.dart';
import 'package:http/http.dart' as http;
import 'dart:math'as math;

var facade = SymbolFacade(Network.TESTNET);
var Networktype = NetworkType.TESTNET;
String XYMID = '72C0212E67A08BCE'; //testnet

NodeJson MyNode = NodeJson();

class NodeJson{
  String endpoint = "";
  int roles = 0;
}

class Account_amount{
  late List<Mosaics> mosaics = [];

  Account_amount({required this.mosaics});

  Account_amount.fromJson(Map<String,dynamic> json){
    json['mosaics']?.forEach((element) {
      mosaics.add(Mosaics.fromJson(element));
    });
  }
}

class Mosaics{
  late String id;
  late double amount;
  Mosaics({required this.id, required this.amount});

  Mosaics.fromJson(Map<String,dynamic> json){
    id = json['id'];
    amount = double.tryParse(json['amount'])!;
  }

}

Future<String> GetDataFromAPI(String Address)async{
  // HTTPリクエストを送信してレスポンスを取得
  var response = await http.get(Uri.parse('https://${MyNode.endpoint}:3001/accounts/$Address'));
  if (response.statusCode == 200) {
    // レスポンスの文字列を返す
    return response.body;
  } else {
    // レスポンスが失敗した場合はエラーをスローするなどの処理を行う
    print('APIからのデータの取得に失敗しました: ${response.statusCode}');
    return '';
  }
}

Future<void> setNode_Test() async {
  final client = http.Client();
  String Node = "";
  do {
    int num = math.Random().nextInt(NodeList_t.length);
    Node = 'https://${NodeList_t[num]}:3001';
    String url = '$Node/node/health';
    try{
      final response = await client.get(
        Uri.parse(url),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        MyNode.endpoint = NodeList_t[num];
        return;
      }else{
        NodeList_t.removeAt(num);
        if (NodeList_t.isEmpty) {
          Node = '';
        }
      }
    }catch(e){
      print(e);
      NodeList_t.removeAt(num);
      if (NodeList_t.isEmpty) {
        return;
      }
    }
  }while(Node != '');
}

void setNode_Main(){

}

Future<double> setXYM(String Address) async{
  const JsonDecoder decoder = JsonDecoder();
  if(Address.isNotEmpty){
    String Datastring = await GetDataFromAPI(Address);
    if(Datastring == ''){
      print('Nothing');
    }else {
      Map<String,dynamic> Jdata = decoder.convert(Datastring);
      Account_amount Ac = Account_amount.fromJson(Jdata['account']);
      for (var element in Ac.mosaics) {
        if(element.id == XYMID) {
          var amount = element.amount * math.pow(10, -6);
          return amount;
        }
      }
    }
  }
  return 0.0;
}

Future<String> Tx_Send(Account Sender, double fee, String Usage) async{
  var keyPair_me = KeyPair(ct.PrivateKey(MyAc!.PrivateKey));
  var keyPair_send = KeyPair(ct.PrivateKey(Sender.PrivateKey));
  var AggTx = AggregateCompleteTransactionV2(
    network: Networktype,
    signerPublicKey: PublicKey(MyAc!.PublicKey),
    deadline: Timestamp(facade.network.fromDatetime(DateTime.now().toUtc()).addHours(2).timestamp),
  );
  //sender->MyAc
  var tx1 = EmbeddedTransferTransactionV1(
    signerPublicKey: PublicKey(Sender.PublicKey),
    network: Networktype,
    recipientAddress: UnresolvedAddress(MyAc!.Address),
    mosaics: <UnresolvedMosaic>[
      UnresolvedMosaic(
          mosaicId: UnresolvedMosaicId(XYMID),
          amount: Amount((fee * math.pow(10,6)).toInt())
      ),
    ],
  );
  AggTx.transactions.add(tx1);
  //Recipt Message
  var tx2 = EmbeddedTransferTransactionV1(
      signerPublicKey: PublicKey(MyAc!.PublicKey),
      network: Networktype,
      recipientAddress: UnresolvedAddress(Sender.Address),
      message: MessageEncorder.toPlainMessage(Recipt(langint(),MyAc!.AccountName,Sender.AccountName,fee, Usage))
  );
  AggTx.transactions.add(tx2);
  var markleHash = SymbolFacade.hashEmbeddedTransactions(AggTx.transactions);
  AggTx.fee = Amount((AggTx.size + 1 * 104) * 100);
  AggTx.transactionsHash = Hash256(markleHash.bytes);
  var signature = facade.signTransaction(keyPair_me, AggTx);
  facade.attachSignature(AggTx, signature);
  var cosignature = facade.cosignTransaction(keyPair_send, AggTx);
  AggTx.cosignatures = [cosignature];
  var hexPayload = bytesToHex(AggTx.serialize());
  var payload = '{"payload": "$hexPayload"}';
  try{
    http.put(
        Uri.parse('https://${MyNode.endpoint}:3001/transactions'),
        headers: {'Content-Type': 'application/json'},
        body: payload
    ).then((response){
      print(response.body);
    });
    return 'Success';
  }catch(e){
    print(e);
    return 'Transaction Error';
  }finally{
  }
}

