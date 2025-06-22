import 'encrypt.dart';


List<String> NodeList_t = ['vmi831828.contaboserver.net', 'testnet1.symbol-mikun.net','sym-test-01.opening-line.jp','2.dusanjp.com'];

Account? MyAc;

class Account{
  late  String AccountName;
  late  String Address;
  late  String PublicKey;
  late  String PrivateKey;
  Account({required this.AccountName, required this.Address, required this.PublicKey, required this.PrivateKey});

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  void ReturnAccount(String Pass,String uid){
    this.AccountName = decryptData(this.AccountName, uid, Pass);
    this.Address = decryptData(this.Address, uid, Pass);
    this.PublicKey = decryptData(this.PublicKey, uid, Pass);
    this.PrivateKey = decryptData(this.PrivateKey, uid, Pass);
  }
}


Account _$AccountFromJson(Map<String, dynamic> json) => Account(
  AccountName: json['AccountName'] as String,
  Address: json['Address'] as String,
  PublicKey: json['PublicKey'] as String,
  PrivateKey: json['PrivateKey'] as String,
);

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
  'AccountName': instance.AccountName,
  'Address': instance.Address,
  'PublicKey': instance.PublicKey,
  'PrivateKey': instance.PrivateKey,
};

