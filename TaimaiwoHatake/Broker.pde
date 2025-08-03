// ブローカーの基本アクションを定義するクラス
// Player.pdeやAI.pdeで継承して使用する
class Broker {
  int[][] handCards;  //手札[米のid][古米情報]
  int[][] loadCards;  //積載（出荷前）[米のid][古米情報]
  int wallet;
  
  Broker(int wallet) {
    //メンバ変数の初期設定
    handCards = new int[RICE_BRANDS.length][4];
    loadCards = new int[RICE_BRANDS.length][4];
    this.wallet = wallet;
  }
  
   //米が古くなる関数
  void decayRice() {
    for (int i = 3; i > 0; i--) {
      handCards[i] = handCards[i-1];
    }
    handCards[0] = new int[4];
  }
  void buyRice(int riceType, int count) {
    
  }
  
  void sellRice(int riceType, int count) {
    
  }
}
