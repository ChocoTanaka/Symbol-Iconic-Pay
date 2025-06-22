
bool lang = false;

int langint(){
  if(lang == false){
    return 0;
  }
  else{
    return 1;
  }
}

String Language(int langi){
  switch(langi){
    case 0:
      return "EN";
    case 1:
      return "JP";
  }
  return "Wrong language setting";
}

String SetNode(int langi){
  switch(langi){
    case 0:
      return "No node connection";
    case 1:
      return "ノードが接続されていません";
  }
  return "Wrong language setting";
}
String Name(int langi){
  switch(langi){
    case 0:
      return "Name:";
    case 1:
      return "名前:";
  }
  return "Wrong language setting";
}

String Resister(int langi){
  switch(langi){
    case 0:
      return "Resister";
    case 1:
      return "登録";
  }
  return "Wrong language setting";
}

String Pay(int langi){
  switch(langi){
    case 0:
      return "Pay";
    case 1:
      return "支払い";
  }
  return "Wrong language setting";
}

String Usage(int langi){
  switch(langi){
    case 0:
      return "Usage:";
    case 1:
      return "題目";
  }
  return "Wrong language setting";
}

String ScanNFC(int langi){
  switch(langi){
    case 0:
      return "Scan your NFC Card.";
    case 1:
      return "カードをスキャンしてください";
  }
  return "Wrong language setting";
}

String Set_pass(int langi){
  switch(langi){
    case 0:
      return "Set this passcode";
    case 1:
      return "パスコードを設定してください";
  }
  return "Wrong language setting";
}

String Enter_pass(int langi){
  switch(langi){
    case 0:
      return "Put on this passcode";
    case 1:
      return "パスコードを記入してください";
  }
  return "Wrong language setting";
}

String Pass_Error_length(int langi, int rest){
  switch(langi){
    case 0:
      return "Passcord is 8 digit. Rest:$rest";
    case 1:
      return "パスコードは8桁で入力してください。残り$rest回";
  }
  return "Wrong language setting";
}

String Shortage_title(int langi){
  switch(langi){
    case 0:
      return "XYM Shortage";
    case 1:
      return "XYMが足りません";
  }
  return "Wrong language setting";
}

String Pay_title(int langi){
  switch(langi){
    case 0:
      return "XYM Check";
    case 1:
      return "XYM確認";
  }
  return "Wrong language setting";
}

String Error_Info(int langi){
  switch(langi){
    case 0:
      return "No Info. Need Resiser";
    case 1:
      return "前のページで登録してください。";
  }
  return "Wrong language setting";
}

String Recipt(int langi, String Name, String Sighner_Name,double cost, String Usage){
  switch(langi) {
    case 0:
      return "Recipt \n"
          + "Name: $Sighner_Name \n"
          + "Cost: $cost XYM\n"
          + "As a use of $Usage\n"
          + "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day} "
          + "$Name";
    case 1:
      return "領収証\n"
          + "$Sighner_Name 様\n"
          + "代金 $cost XYM\n"
          + "$Usage として\n"
          + "${DateTime.now().year}/${DateTime.now().month}/${DateTime.now().day} "
          + "$Name";
  }
  return "Wrong language setting";
}

String Txconfirmed(int langi){
  switch(langi){
    case 0:
      return "Tx Confirmed.";
    case 1:
      return "トランザクションが承認されました。";
  }
  return "Wrong language setting";
}
