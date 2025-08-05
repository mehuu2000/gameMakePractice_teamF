// NPCの動きを制御するクラス
// Broker.pdeから継承して使用

class AI extends Broker {
  float[] buyCostAverages;
  
  AI(int wallet) {
    super(wallet);
    buyCostAverages = new float[riceBrandsInfo.length]; //購入金額の平均
  }
  
  // AIの行動を定義するメソッド
  void aiAction() {
    // 購入プロセス ランキング順に安い方から買っていく
    int[] ranking = market.getBrandRanking();
    for (int i = riceBrandsInfo.length - 1; i >= 0; i--) {
      int riceID = ranking[i];
      int countRice = getSumHandRice(riceID);
      int canBuyCount = riceBrandsInfo[riceID].point / wallet; // 全額使ったら買える個数
      if (i!=0) {
        this.buyRice(riceID, canBuyCount/2);
        buyCostAverages[riceID] = (countRice * getSumHandRice(riceID)
                                          + riceBrandsInfo[riceID].point * canBuyCount/2)
                                          / (countRice + canBuyCount/2);
      }else{
        this.buyRice(riceID, canBuyCount);
        buyCostAverages[riceID] = (countRice * getSumHandRice(riceID)
                                          + riceBrandsInfo[riceID].point * canBuyCount)
                                          / (countRice + canBuyCount);
      }
    }
    
    //出荷場に置くプロセス　
  }
}
