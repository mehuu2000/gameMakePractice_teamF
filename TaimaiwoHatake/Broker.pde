// ブローカーの基本アクションを定義するクラス
// Player.pdeやAI.pdeで継承して使用する
class Broker {
  int[][] handCards;  //手札[米のid][古米情報]
  int[][] loadCards;  //積載（出荷前）[米のid][古米情報]
  int wallet;
  
  Broker(int wallet) {
    //メンバ変数の初期設定
    handCards = new int[RICE_BRANDS_INFO.length][4];
    loadCards = new int[RICE_BRANDS_INFO.length][4];
    this.wallet = wallet;
  }
  
  //米をIDごとの手札の合計を返す関数
  int getSumHandRice(int riceID) {
    int sumHandRice = 0;
    for (int i = 0; i < 4; i++) {
      sumHandRice += handCards[riceID][i];
    }
    return sumHandRice;
  }
  
  //米をIDごとの出荷数の合計を返す関数
  int getSumLoadRice(int riceID) {
    int sumLoadRice = 0;
    for (int i = 0; i < 4; i++) {
      sumLoadRice += loadCards[riceID][i];
    }
    return sumLoadRice;
  }
  
  //米が古くなる関数
  void decayRice() {
    // 全ての行に対してループ
    for (int i = 0; i < handCards.length; i++) {
      // 各行の列を後ろから前にループ
      for (int j = 4 - 1; j > 0; j--) {
        // 左の列(j-1)の値を現在の列(j)に代入
        handCards[i][j] = handCards[i][j-1];
      }
      // 空いた先頭の列に0を入れる
      handCards[i][0] = 0;
    }
  }
  
  //米を買う関数　引数:米のid, 個数　返り値:購入成功->true 購入失敗->false
  boolean buyRice(int riceID, int count) {
    int cost = RICE_BRANDS_INFO[riceID].point * count;
    if (cost > wallet) {
      return false;
    }else{
      wallet -= cost;
      handCards[riceID][0] += count;
      return true;
    }
  }
  
  //米を出荷する関数　引数:米のid, 個数　返り値:購入成功->true 購入失敗->false
  boolean loadRice(int riceID, int count) {
    if (getSumHandRice(riceID) < count) {
      return false; // 手札が足りない
    }
    int countToLoad = count;
    // 古い米(i=3)からループ
    for (int i = 3; i >= 0; i--) {
      int amountToMove = min(handCards[riceID][i], countToLoad);
      if (amountToMove > 0) {
        handCards[riceID][i] -= amountToMove;
        loadCards[riceID][i] += amountToMove; // loadCardsに追加する処理
        countToLoad -= amountToMove;
      }
      if (countToLoad <= 0) {
        break;
      }
    }
    return true;
  }
  
  //米を出荷から戻す関数　引数:米のid, 個数　返り値:返却成功->true 返却失敗->false
  boolean backRice(int riceID, int count) {
    if (getSumLoadRice(riceID) < count) {
      return false; // 積載量が足りない
    }
    int countToReturn = count;
    // 新しい米(i=0)からループ
    for (int i = 0; i <= 3; i++) {
      int amountToMove = min(loadCards[riceID][i], countToReturn);
      if (amountToMove > 0) {
        loadCards[riceID][i] -= amountToMove;
        handCards[riceID][i] += amountToMove;
        countToReturn -= amountToMove;
      }
      if (countToReturn <= 0) {
        break;
      }
    }
    return true;
  }
  
  //米を売る関数
  void sellRice() {
    int sellPrice = 0;
    for (int i = 0; i < RICE_BRANDS_INFO.length; i++) {
      for (int j = 0; j < 4; j++) {
        sellPrice += loadCards[i][j] * RICE_BRANDS_INFO[i].point;
        loadCards[i][j] = 0;
      }
    }
    wallet += sellPrice;
  }
}
