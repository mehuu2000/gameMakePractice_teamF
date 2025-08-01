// 市場クラス
class Market {
  int[] marketStock = new int[4]; // 各ブランドの在庫
  int supplyLimit; // 供給上限
  String currentEnvironment = "通常";
  float[] basePrices = {10000, 10000, 10000, 10000}; // 基本価格（1万円）
  
  Market() {
    // 初期在庫設定
    for (int i = 0; i < 4; i++) {
      marketStock[i] = int(random(5, 15));
    }
    
    // 供給上限設定（30-40枚）
    supplyLimit = int(random(30, 41));
  }
  
  // 現在の価格を計算
  float getCurrentPrice(int brandType) {
    // 市場の総数を計算
    int[] totalCounts = new int[4];
    for (int i = 0; i < 4; i++) {
      totalCounts[i] = marketStock[i];
    }
    
    // ソートして順位を決定
    int[] sorted = totalCounts.clone();
    sorted = sort(sorted);
    
    // 価格倍率を決定
    float multiplier = 1.5; // デフォルト（少ない）
    if (marketStock[brandType] == sorted[3]) {
      multiplier = 0.5; // 最も多い
    } else if (marketStock[brandType] == sorted[2]) {
      multiplier = 1.0; // 2番目に多い
    }
    
    return basePrices[brandType] * multiplier;
  }
  
  // ターン処理
  void processTurn(Broker player, Broker ai) {
    // 出荷処理
    processShipping(player);
    processShipping(ai);
    
    // 供給過多チェック
    int totalStock = 0;
    for (int i = 0; i < 4; i++) {
      totalStock += marketStock[i];
    }
    
    if (totalStock > supplyLimit) {
      // 供給過多：全品種の価格が下がる
      for (int i = 0; i < 4; i++) {
        basePrices[i] *= 0.8;
      }
    }
    
    // 消費処理
    consumeRice();
    
    // 環境効果（ランダム）
    if (random(1) < 0.3) {
      applyEnvironmentEffect();
    }
  }
  
  // 出荷処理
  void processShipping(Broker broker) {
    // 売上計算
    float totalRevenue = 0;
    
    for (RiceCard card : broker.shippingArea) {
      float price = getCurrentPrice(card.brandType);
      totalRevenue += price;
      marketStock[card.brandType]++;
    }
    
    broker.money += int(totalRevenue);
    broker.shippingArea.clear();
  }
  
  // 消費処理
  void consumeRice() {
    // 各ブランドから確率的に消費
    for (int i = 0; i < 4; i++) {
      if (marketStock[i] > 0) {
        // 基本消費量を増やす（3-8枚）
        int baseConsumption = int(random(3, 9));
        
        // 在庫が多いほど消費が増える
        if (marketStock[i] > 20) {
          baseConsumption += int(random(2, 5));
        }
        
        // 豊穣祭の場合はさらに消費増
        if (currentEnvironment.equals("豊穣祭")) {
          baseConsumption = int(baseConsumption * 1.5);
        }
        
        int consumed = min(baseConsumption, marketStock[i]);
        marketStock[i] -= consumed;
      }
    }
  }
  
  // 環境効果適用
  void applyEnvironmentEffect() {
    float rand = random(1);
    if (rand < 0.3) {
      currentEnvironment = "豊作";
      // 価格が下がる
      for (int i = 0; i < 4; i++) {
        basePrices[i] *= 0.9;
      }
    } else if (rand < 0.6) {
      currentEnvironment = "不作";
      // 価格が上がる
      for (int i = 0; i < 4; i++) {
        basePrices[i] *= 1.1;
      }
    } else if (rand < 0.8) {
      currentEnvironment = "台風";
      // 特定ブランドの在庫が減る
      int affectedBrand = int(random(4));
      marketStock[affectedBrand] = max(0, marketStock[affectedBrand] - int(random(5, 10)));
    } else {
      currentEnvironment = "豊穣祭";
      // 消費が増える（consumeRiceで処理）
    }
  }
}