// イベント効果管理システム
// 各種係数を個別に管理し、複数のイベントが重複しても正しく動作する

// 効果の種類を定義
enum EffectType {
  BUY_PRICE_ALL,        // 全ブランドの買値
  SELL_PRICE_ALL,       // 全ブランドの売値
  BUY_PRICE_BRAND,      // 特定ブランドの買値
  SELL_PRICE_BRAND,     // 特定ブランドの売値
  OLD_RICE_PRICE,       // 古米・古古米の価格
  SUPPLY_AMOUNT,        // 仕入れ量
  CONSUMPTION_RATE,     // 消費率
  PLAYER_MONEY,         // プレイヤー所持金（加算）
  AI_MONEY,             // AI所持金（加算）
  MARKET_STOCK_ALL,     // 市場在庫（全体）
  MARKET_STOCK_BRAND    // 市場在庫（特定ブランド）
}

// 個別の効果を表すクラス
class EventEffectItem {
  EffectType type;        // 効果の種類
  float multiplier;       // 倍率（1.0が基準）
  int addValue;          // 加算値（金額や在庫数など）
  int brandId;           // ブランドID（特定ブランドの場合）
  String eventSource;     // この効果を発生させたイベント名
  boolean isTemporary;    // 一時的な効果かどうか
  
  EventEffectItem(EffectType type, float multiplier, int addValue, int brandId, String source) {
    this.type = type;
    this.multiplier = multiplier;
    this.addValue = addValue;
    this.brandId = brandId;
    this.eventSource = source;
    this.isTemporary = true;
  }
}

// イベント効果管理クラス
class EventEffectManager {
  ArrayList<EventEffectItem> activeEffects;
  
  // 基準値（効果なしの状態）
  float baseBuyPriceMultiplier = 1.0;
  float baseSellPriceMultiplier = 1.0;
  float baseSupplyMultiplier = 1.0;
  float baseConsumptionMultiplier = 1.0;
  
  EventEffectManager() {
    activeEffects = new ArrayList<EventEffectItem>();
  }
  
  // 効果を追加
  void addEffect(EventEffectItem effect) {
    activeEffects.add(effect);
    println("効果追加: " + effect.eventSource + " - " + effect.type + " x" + effect.multiplier);
  }
  
  // 特定イベントの効果を削除
  void removeEffectsByEvent(String eventName) {
    for (int i = activeEffects.size() - 1; i >= 0; i--) {
      if (activeEffects.get(i).eventSource.equals(eventName)) {
        println("効果削除: " + activeEffects.get(i).eventSource + " - " + activeEffects.get(i).type);
        activeEffects.remove(i);
      }
    }
  }
  
  // 全ブランドの買値倍率を取得（複数効果の累積）
  float getBuyPriceMultiplier() {
    float multiplier = baseBuyPriceMultiplier;
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.BUY_PRICE_ALL) {
        multiplier *= effect.multiplier;
      }
    }
    return multiplier;
  }
  
  // 特定ブランドの買値倍率を取得
  float getBrandBuyPriceMultiplier(int brandId) {
    float multiplier = getBuyPriceMultiplier(); // 全体効果を先に適用
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.BUY_PRICE_BRAND && effect.brandId == brandId) {
        multiplier *= effect.multiplier;
      }
    }
    return multiplier;
  }
  
  // 全ブランドの売値倍率を取得
  float getSellPriceMultiplier() {
    float multiplier = baseSellPriceMultiplier;
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.SELL_PRICE_ALL) {
        multiplier *= effect.multiplier;
      }
    }
    return multiplier;
  }
  
  // 特定ブランドの売値倍率を取得
  float getBrandSellPriceMultiplier(int brandId) {
    float multiplier = getSellPriceMultiplier(); // 全体効果を先に適用
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.SELL_PRICE_BRAND && effect.brandId == brandId) {
        multiplier *= effect.multiplier;
      }
    }
    return multiplier;
  }
  
  // 古米・古古米の価格倍率を取得
  float getOldRicePriceMultiplier() {
    float multiplier = 1.0;
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.OLD_RICE_PRICE) {
        multiplier *= effect.multiplier;
      }
    }
    return multiplier;
  }
  
  // 仕入れ量倍率を取得
  float getSupplyMultiplier() {
    float multiplier = baseSupplyMultiplier;
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.SUPPLY_AMOUNT) {
        multiplier *= effect.multiplier;
      }
    }
    return multiplier;
  }
  
  // 消費率倍率を取得
  float getConsumptionMultiplier() {
    float multiplier = baseConsumptionMultiplier;
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.CONSUMPTION_RATE) {
        multiplier *= effect.multiplier;
      }
    }
    return multiplier;
  }
  
  // プレイヤーへの金額加算を取得（一回のみ）
  int getPlayerMoneyBonus() {
    int bonus = 0;
    for (int i = activeEffects.size() - 1; i >= 0; i--) {
      EventEffectItem effect = activeEffects.get(i);
      if (effect.type == EffectType.PLAYER_MONEY) {
        bonus += effect.addValue;
        // 一回限りの効果なので削除
        activeEffects.remove(i);
      }
    }
    return bonus;
  }
  
  // 市場在庫への加算を取得
  int getMarketStockBonus(int brandId) {
    int bonus = 0;
    for (EventEffectItem effect : activeEffects) {
      if (effect.type == EffectType.MARKET_STOCK_ALL) {
        bonus += effect.addValue;
      } else if (effect.type == EffectType.MARKET_STOCK_BRAND && effect.brandId == brandId) {
        bonus += effect.addValue;
      }
    }
    return bonus;
  }
  
  // デバッグ用：現在の効果一覧を表示
  void printActiveEffects() {
    println("=== 現在有効な効果 ===");
    for (EventEffectItem effect : activeEffects) {
      print(effect.eventSource + ": ");
      print(effect.type + " ");
      if (effect.multiplier != 1.0) {
        print("x" + effect.multiplier + " ");
      }
      if (effect.addValue != 0) {
        print("+" + effect.addValue + " ");
      }
      if (effect.brandId >= 0) {
        print("(ブランド:" + riceBrandsInfo[effect.brandId].name + ")");
      }
      println();
    }
    println("================");
  }
}

// グローバルインスタンス
EventEffectManager effectManager;

// ========== ヘルパー関数 ==========

// 豊作イベント用（特定ブランド）
void applyHarvestEvent(String eventName, int brandId) {
  // 買値を20%低下（0.8倍）
  EventEffectItem buyEffect = new EventEffectItem(
    EffectType.BUY_PRICE_BRAND, 
    0.8, 
    0, 
    brandId, 
    eventName
  );
  effectManager.addEffect(buyEffect);
  
  // 在庫を増やす（5〜15個追加）
  int additionalStock = int(random(5, 15));
  EventEffectItem stockEffect = new EventEffectItem(
    EffectType.MARKET_STOCK_BRAND,
    1.0,
    additionalStock,
    brandId,
    eventName
  );
  effectManager.addEffect(stockEffect);
  market.updateBrandStock(brandId, additionalStock);
}

// 台風イベント用
void applyTyphoonEvent(String eventName) {
  // 仕入れ量を20%減少
  EventEffectItem supplyEffect = new EventEffectItem(
    EffectType.SUPPLY_AMOUNT,
    0.8,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(supplyEffect);
  
  // 市場在庫を減らす
  for (int i = 0; i < riceBrandsInfo.length; i++) {
    int reduction = min(market.getBrandStock(i), int(random(3, 8)));
    market.updateBrandStock(i, -reduction);
  }
}

// 大雪イベント用
void applySnowEvent(String eventName) {
  // 買値を20%上昇
  EventEffectItem effect = new EventEffectItem(
    EffectType.BUY_PRICE_ALL,
    1.2,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
}

// 猛暑イベント用
void applyHeatwaveEvent(String eventName) {
  // 古米・古古米の売値を50%減少
  EventEffectItem effect = new EventEffectItem(
    EffectType.OLD_RICE_PRICE,
    0.5,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
}

// 米騒動イベント用
void applyRiceRiotEvent(String eventName) {
  // 買値・売値を2倍
  EventEffectItem buyEffect = new EventEffectItem(
    EffectType.BUY_PRICE_ALL,
    2.0,
    0,
    -1,
    eventName
  );
  EventEffectItem sellEffect = new EventEffectItem(
    EffectType.SELL_PRICE_ALL,
    2.0,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(buyEffect);
  effectManager.addEffect(sellEffect);
}

// 日本一決定戦イベント用
void applyChampionshipEvent(String eventName, int brandId) {
  // 特定ブランドの売値を1.5倍
  EventEffectItem effect = new EventEffectItem(
    EffectType.SELL_PRICE_BRAND,
    1.5,
    0,
    brandId,
    eventName
  );
  effectManager.addEffect(effect);
}

// 棚からぼたもちイベント用
void applyBonusMoneyEvent(String eventName) {
  // プレイヤーに2000pt追加
  EventEffectItem effect = new EventEffectItem(
    EffectType.PLAYER_MONEY,
    1.0,
    2000,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
  
  // 即座に適用
  int bonus = effectManager.getPlayerMoneyBonus();
  player.wallet += bonus;
  println("プレイヤーに" + bonus + "pt追加！");
}

// 不況イベント用
void applyRecessionEvent(String eventName) {
  // 買値・売値を0.8倍
  EventEffectItem buyEffect = new EventEffectItem(
    EffectType.BUY_PRICE_ALL,
    0.8,
    0,
    -1,
    eventName
  );
  EventEffectItem sellEffect = new EventEffectItem(
    EffectType.SELL_PRICE_ALL,
    0.8,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(buyEffect);
  effectManager.addEffect(sellEffect);
}

// オオカタ・ハズレールの大予言イベント用
void applyProphecyEvent(String eventName) {
  // 買値・売値を2.5倍
  EventEffectItem buyEffect = new EventEffectItem(
    EffectType.BUY_PRICE_ALL,
    2.5,
    0,
    -1,
    eventName
  );
  EventEffectItem sellEffect = new EventEffectItem(
    EffectType.SELL_PRICE_ALL,
    2.5,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(buyEffect);
  effectManager.addEffect(sellEffect);
}

// 大盤振米イベント用
void applySupplyBonusEvent(String eventName) {
  // 仕入れ量を1.2倍
  EventEffectItem effect = new EventEffectItem(
    EffectType.SUPPLY_AMOUNT,
    1.2,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
}

// きりたんぽ鍋ブームイベント用
void applyHotpotBoomEvent(String eventName) {
  // 売値を1.5倍
  EventEffectItem effect = new EventEffectItem(
    EffectType.SELL_PRICE_ALL,
    1.5,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
}

// 買い占めイベント用
void applyHoardingEvent(String eventName) {
  // 消費率を1.5倍
  EventEffectItem effect = new EventEffectItem(
    EffectType.CONSUMPTION_RATE,
    1.5,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
}

// 海外からの安価な米の輸入イベント用
void applyImportEvent(String eventName) {
  // 消費率を0.9倍、売値を0.9倍、買値を0.8倍
  EventEffectItem consumptionEffect = new EventEffectItem(
    EffectType.CONSUMPTION_RATE,
    0.9,
    0,
    -1,
    eventName
  );
  EventEffectItem sellEffect = new EventEffectItem(
    EffectType.SELL_PRICE_ALL,
    0.9,
    0,
    -1,
    eventName
  );
  EventEffectItem buyEffect = new EventEffectItem(
    EffectType.BUY_PRICE_ALL,
    0.8,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(consumptionEffect);
  effectManager.addEffect(sellEffect);
  effectManager.addEffect(buyEffect);
}

// 農業体験ブームイベント用
void applyAgricultureBoomEvent(String eventName) {
  // 仕入れ量を1.1倍
  EventEffectItem effect = new EventEffectItem(
    EffectType.SUPPLY_AMOUNT,
    1.1,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
}

// 農家の後継者問題イベント用
void applyFarmerRetirementEvent(String eventName) {
  // 仕入れ量を0.9倍
  EventEffectItem effect = new EventEffectItem(
    EffectType.SUPPLY_AMOUNT,
    0.9,
    0,
    -1,
    eventName
  );
  effectManager.addEffect(effect);
}

// イベント終了時の効果削除
void removeEventEffects(String eventName) {
  effectManager.removeEffectsByEvent(eventName);
}