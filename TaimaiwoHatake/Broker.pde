// ブローカーの基本アクションを定義するクラス
// Player.pdeやAI.pdeで継承して使用する

// ========== 定数 ==========
final int RICE_DECAY_LIMIT = 3;
final float RICE_BUY_RATIO = 0.8;

//クラス宣言
class Broker {
  int[][] handRices;  //手札[米のid][古米情報]
  int[][] loadRices;  //積載（出荷前）[米のid][古米情報]
  int[] sumLoadRices;   //出荷[米のid]
  int wallet;
  
  Broker(int wallet) {
    //メンバ変数の初期設定
    handRices = new int[riceBrandsInfo.length][RICE_DECAY_LIMIT];
    loadRices = new int[riceBrandsInfo.length][RICE_DECAY_LIMIT];
    sumLoadRices = new int[riceBrandsInfo.length];
    this.wallet = wallet;
  }
  
  //米をIDごとの手札の合計を返す関数
  int getSumHandRice(int riceID) {
    int sumHandRice = 0;
    for (int i = 0; i < RICE_DECAY_LIMIT; i++) {
      sumHandRice += handRices[riceID][i];
    }
    return sumHandRice;
  }
  
  //米をIDごとの出荷数の合計を返す関数
  int getSumLoadRice(int riceID) {
    int sumLoadRice = 0;
    for (int i = 0; i < RICE_DECAY_LIMIT; i++) {
      sumLoadRice += loadRices[riceID][i];
    }
    return sumLoadRice;
  }
  
  //米が古くなる関数
  void decayRice() {
    // 全ての行に対してループ
    for (int i = 0; i < handRices.length; i++) {
      // 各行の列を後ろから前にループ
      for (int j = RICE_DECAY_LIMIT - 1; j > 0; j--) {
        // 左の列(j-1)の値を現在の列(j)に代入
        handRices[i][j] = handRices[i][j-1];
      }
      // 空いた先頭の列に0を入れる
      handRices[i][0] = 0;
    }
  }
  
  //米を買う関数　引数:米のid, 個数　返り値:購入成功->true 購入失敗->false
  boolean buyRice(int riceID, int count) {
    int cost = int(riceBrandsInfo[riceID].point * RICE_BUY_RATIO) * count;
    if (cost > wallet) {
      return false;
    }else{
      wallet -= cost;
      handRices[riceID][0] += count;
      return true;
    }
  }
  
  //米を出荷場に出す関数　引数:米のid, 個数　返り値:購入成功->true 購入失敗->false
  boolean loadRice(int riceID, int count) {
    if (getSumHandRice(riceID) < count) {
      return false; // 手札が足りない
    }
    int countToLoad = count;
    // 古い米(i=RICE_DECAY_LIMIT - 1)からループ
    for (int i = RICE_DECAY_LIMIT - 1; i >= 0; i--) {
      int amountToMove = min(handRices[riceID][i], countToLoad);
      if (amountToMove > 0) {
        handRices[riceID][i] -= amountToMove;
        loadRices[riceID][i] += amountToMove; // loadCardsに追加する処理
        countToLoad -= amountToMove;
      }
      if (countToLoad <= 0) {
        break;
      }
    }
    return true;
  }
  
  //米を出荷場から戻す関数　引数:米のid, 個数　返り値:返却成功->true 返却失敗->false
  boolean backRice(int riceID, int count) {
    if (getSumLoadRice(riceID) < count) {
      return false; // 積載量が足りない
    }
    int countToReturn = count;
    // 新しい米(i=0)からループ
    for (int i = 0; i <= RICE_DECAY_LIMIT - 1; i++) {
      int amountToMove = min(loadRices[riceID][i], countToReturn);
      if (amountToMove > 0) {
        loadRices[riceID][i] -= amountToMove;
        handRices[riceID][i] += amountToMove;
        countToReturn -= amountToMove;
      }
      if (countToReturn <= 0) {
        break;
      }
    }
    return true;
  }
  
  //米を出荷する関数
  void shipRice() {
    sumLoadRices = new int[riceBrandsInfo.length];
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      sumLoadRices[i] = getSumLoadRice(i);
    }
    market.ship(sumLoadRices);
  }
  
  //米を売る関数
  void sellRice() {
    int profit = market.calculateProfit(sumLoadRices);
    wallet += profit;
    loadRices = new int[riceBrandsInfo.length][RICE_DECAY_LIMIT];
  }
}
