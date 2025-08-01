// ブローカー（プレイヤー/AI）クラス
class Broker {
  String name;
  int money;
  ArrayList<RiceCard> hand;
  ArrayList<RiceCard> shippingArea;
  
  Broker(String name, int initialMoney) {
    this.name = name;
    this.money = initialMoney;
    this.hand = new ArrayList<RiceCard>();
    this.shippingArea = new ArrayList<RiceCard>();
  }
  
  // カードを手札に追加
  void addCard(RiceCard card) {
    hand.add(card);
  }
  
  // カードを出荷準備エリアに移動
  void moveToShipping(int brandType, int amount) {
    int moved = 0;
    
    for (int i = hand.size() - 1; i >= 0 && moved < amount; i--) {
      if (hand.get(i).brandType == brandType) {
        shippingArea.add(hand.remove(i));
        moved++;
      }
    }
  }
  
  // 出荷準備エリアから手札に戻す
  void moveFromShipping(int brandType, int amount) {
    int moved = 0;
    
    for (int i = shippingArea.size() - 1; i >= 0 && moved < amount; i--) {
      if (shippingArea.get(i).brandType == brandType) {
        hand.add(shippingArea.remove(i));
        moved++;
      }
    }
  }
  
  // 指定ブランドの手札枚数を取得
  int getHandCount(int brandType) {
    int count = 0;
    for (RiceCard card : hand) {
      if (card.brandType == brandType) {
        count++;
      }
    }
    return count;
  }
  
  // 指定ブランドの出荷準備枚数を取得
  int getShippingCount(int brandType) {
    int count = 0;
    for (RiceCard card : shippingArea) {
      if (card.brandType == brandType) {
        count++;
      }
    }
    return count;
  }
  
  // 買付処理
  boolean buyCard(int brandType, float price) {
    if (money >= price) {
      money -= int(price);
      addCard(new RiceCard(brandType));
      return true;
    }
    return false;
  }
  
  // AI用の思考ルーチン
  void aiTurn(Market market) {
    // 価格を分析して買付判断
    ArrayList<Integer> goodBuys = new ArrayList<Integer>();
    
    for (int i = 0; i < 4; i++) {
      float price = market.getCurrentPrice(i);
      // 価格が安い（基準価格の80%以下）ブランドを優先
      if (price <= 8000) {
        goodBuys.add(i);
      }
    }
    
    // 買付処理（毎ターン1-3枚程度）
    int buyCount = int(random(1, 4));
    for (int i = 0; i < buyCount && money > 20000; i++) {
      int brandToBuy;
      if (goodBuys.size() > 0) {
        // 安いブランドから選ぶ
        brandToBuy = goodBuys.get(int(random(goodBuys.size())));
      } else {
        // ランダムに選ぶ
        brandToBuy = int(random(4));
      }
      
      float price = market.getCurrentPrice(brandToBuy);
      if (money >= price) {
        buyCard(brandToBuy, price);
      }
    }
    
    // 出荷準備エリアをクリア（startNewTurnで行うのでここでは不要）
    // 出荷はstartNewTurnで別途処理
  }
}