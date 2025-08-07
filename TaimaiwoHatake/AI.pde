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
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      int riceID = ranking[i];
      int countRice = getSumHandRice(riceID);
      int canBuyCount = wallet / riceBrandsInfo[riceID].point; // 全額使ったら買える個数
      if (i!=0) {
        buyRice(riceID, canBuyCount/2);
        buyCostAverages[riceID] = (countRice * getSumHandRice(riceID)
                                          + riceBrandsInfo[riceID].point * canBuyCount/2)
                                          / float(countRice + canBuyCount/2);
      }else{
        buyRice(riceID, canBuyCount);
        buyCostAverages[riceID] = (countRice * getSumHandRice(riceID)
                                          + riceBrandsInfo[riceID].point * canBuyCount)
                                          / float(countRice + canBuyCount);
      }
    }
    
    //出荷場に置くプロセス
    //次腐ってしまう米を全て出荷場に出す
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      int oldestRice = handRices[i][RICE_DECAY_LIMIT - 1];
      if (oldestRice > 0)
        loadRice(i, oldestRice);
    }
    //価値の高い方から1/2, 3/8, 1/4, 1/8の順に出荷場に出す
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      int riceID = ranking[i];
      int countRice = getSumHandRice(riceID);
      switch(4 - i) {
        case 1:
          loadRice(riceID, countRice/2);
          break;
        case 2:
          loadRice(riceID, countRice*3/8);
          break;
        case 3:
          loadRice(riceID, countRice/4);
          break;
        case 4:
          loadRice(riceID, countRice/8);
          break;
      }
    }
  }
  
  int[] predPrice(boolean perfectPred){
    int[] predPrices;
    for (int i = 0; i < riceBrandsInfo.length, i++) {
      predPrices = riceBrandsInfo[i].point;
    }
    if (perfectPred) {
      
    }
    return predPrices
  }
}
