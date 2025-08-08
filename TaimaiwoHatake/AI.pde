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
    int eventbuyCount = 2; // デフォルト値
    
    // イベントを確認（nullチェック付き）
    String eventName = "通常";
    if (eventManager != null && 
        eventManager.eventSchedule != null && 
        currentTurn < eventManager.eventSchedule.length && 
        eventManager.eventSchedule[currentTurn] != null) {
      eventName = eventManager.eventSchedule[currentTurn].eventName;
      println(eventName);
    }
    
    switch (eventName) {
      case "台風":
      case "大雪":
        eventbuyCount = 0;
        break;
      case "米騒動":
        eventbuyCount = 1;
        break;
      case "豊作":
      case "花見需要":
        eventbuyCount = 4;
        break;
      default:
        eventbuyCount = 3;
        break;
    }
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      int riceID = ranking[i];
      int countRice = getSumHandRice(riceID);
      int canBuyCount = wallet / riceBrandsInfo[riceID].point; // 全額使ったら買える個数
      if (canBuyCount <= 0 || eventbuyCount <= 0) {
        // 購入しない場合は前の値を保持（初期値0の場合は現在の価格を設定）
        if (buyCostAverages[riceID] == 0) {
          buyCostAverages[riceID] = riceBrandsInfo[riceID].point * RICE_BUY_RATIO;
        }
      } else {
        int buyCount = min(canBuyCount/2, eventbuyCount);
        if (buyCount > 0) {
          buyRice(riceID, buyCount);
          // 初回購入時または0除算を防ぐ処理
          if (countRice == 0) {
            buyCostAverages[riceID] = riceBrandsInfo[riceID].point * RICE_BUY_RATIO;
          } else {
            buyCostAverages[riceID] = (countRice * buyCostAverages[riceID]
                                              + riceBrandsInfo[riceID].point * RICE_BUY_RATIO * buyCount)
                                              / float(countRice + buyCount);
          }
        }
      }
      println(buyCostAverages[riceID]);
    }
    
    //出荷場に置くプロセス
    //次腐ってしまう米を全て出荷場に出す
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      int oldestRice = handRices[i][RICE_DECAY_LIMIT - 1];
      if (oldestRice > 0)
        loadRice(i, oldestRice);
    }
    /*//価値の高い方から1/2, 3/8, 1/4, 1/8の順に出荷場に出す
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
    }*/
    int[] loadCount = predCount();
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      loadRice(i, loadCount[i]);
    }
  }
  
  int[] predCount(){
    // 完全正確な予測
    int[] AIHandRices = new int[riceBrandsInfo.length];
    int[] playerLoadRices = new int[riceBrandsInfo.length];
    int sumPlayerLoadRice = 0;
    for (int i = 0; i < riceBrandsInfo.length; i++) {
      playerLoadRices[i] = player.getSumLoadRice(i);
      sumPlayerLoadRice += playerLoadRices[i];
      AIHandRices[i] = ai.getSumHandRice(i);
    }
    int[] bestCombi = new int[riceBrandsInfo.length];
    int[] tempPrice = new int[riceBrandsInfo.length];
    int tempProfit = 0;
    int maxProfit = 0;
    for (int i = 0; i <= AIHandRices[0]; i++) {
      for (int j = 0; j <= AIHandRices[1]; j++) {
        for (int k = 0; k <= AIHandRices[2]; k++) {
          for (int l = 0; l <= AIHandRices[3]; l++) {
            tempProfit = 0;
            int[] AILoadCount = {i, j, k, l};
            float totalAmount =  market.getTotalStock()+1 + sumPlayerLoadRice +(i+j+k+l); 
            float totalSupplyAdjustmentFactor = (market.supplyLimit / totalAmount); // 供給数補正係数
            for (int m = 0; m < riceBrandsInfo.length; m++) {
                float rarityAdjustmentFactor = totalAmount / (market.marketStock[m]+2 + AILoadCount[m]); // 希少性補正係数
                // ブランドの価格を更新
                tempPrice[m] = int(BASE_CARD_POINTS[m] * (totalSupplyAdjustmentFactor * 0.8) * rarityAdjustmentFactor * 0.7 * eventEffect);
                // 価格が0以下にならないように制御
                if (tempPrice[m] <= LOWER_LIMIT_RICE_POINT) {
                    tempPrice[m] = LOWER_LIMIT_RICE_POINT; // 最低価格はLOWER_LIMIT_RICE_POINT pt
                }
                tempProfit += (tempPrice[m] - buyCostAverages[m]) * AILoadCount[m];
            }
            if (maxProfit < tempProfit) {
              for (int m=0; m < riceBrandsInfo.length; m++) {
                bestCombi[m] = AILoadCount[m];
              }
            }
          }
        }
      }
    }
    println("AIの手札"+ getSumHandRice(0)+ getSumHandRice(1)+ getSumHandRice(2)+ getSumHandRice(3) +"AIの行動："+bestCombi[0]+bestCombi[1]+bestCombi[2]+bestCombi[3]);
    return bestCombi;
  }
}
