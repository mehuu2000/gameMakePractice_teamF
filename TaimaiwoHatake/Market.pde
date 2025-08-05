// 市場の処理などを行うクラス
class Market {
    // ========== 市場在庫管理 ==========
    int[] marketStock;  //インデックス = 0: りょうおもい, 1: ほしひかり, 2:ゆめごこち, 3:つやおうじ | 値 = 在庫数

    // ========== 供給管理 ==========
    int supplyLimit;         // 供給上限

    // ========== 環境効果 ==========
    String currentEnvironment;  // 現在の環境（豊作、不作など)

    // ========== 定数 ==========
    // 供給上限の範囲
    final int MIN_SUPPLY_LIMIT = 50;
    final int MAX_SUPPLY_LIMIT = 100;

    // 初期在庫生成の割合
    final float INIT_STOCK_MIN_RATIO = 0.1;  // 供給上限の1/10
    final float INIT_STOCK_MAX_RATIO = 0.25;  // 供給上限の1/4

    // 消費率
    final float CONSUME_MIN_RATIO = 0.2;  // 最小20%消費
    final float CONSUME_MAX_RATIO = 0.4;  // 最大40%消費

    // コンストラクタ
    Market() {
        marketStock = new int[riceBrandsInfo.length]; // ブランドの在庫 (riceBrandsInfo配列のサイズ分)
        setSupplyLimit(); // 供給上限を設定
        initStockGeneration(supplyLimit); // 初期在庫を生成
        currentEnvironment = "NORMAL"; // 初期環境は通常
    }

    // ========== 市場在庫の初期化 ==========
    // 初期供給上限を50-100の間でランダムに生成
    void setSupplyLimit() {
        supplyLimit = int(random(MIN_SUPPLY_LIMIT, MAX_SUPPLY_LIMIT+1));
    }

    // 初期のブランド在庫を設定
    // ここでは、各ブランドの初期在庫を供給上限を参考にして設定
    void initStockGeneration(int supplyLimit) {
        int startCount = int(supplyLimit * INIT_STOCK_MIN_RATIO);
        int finishCount = int(supplyLimit * INIT_STOCK_MAX_RATIO);
        int initTotalCount = int(random(startCount, finishCount));
        for (int i=0; i<initTotalCount; i++) {
            // ランダムでインデックスを選択
            int brandIndex = int(random(0, marketStock.length));
            marketStock[brandIndex]++;
        }
    }

    // ========== 市場の情報を取得 ==========
    // 市場の総在庫数を取得
    int getTotalStock() {
        int total = 0;
        for (int stock : marketStock) {
            total += stock;
        }
        return total;
    }

    // 各ブランドの在庫数を取得
    int getBrandStock(int brandIndex) {
        if (brandIndex < 0 || brandIndex >= marketStock.length) {
            return -1; // 無効なインデックスの場合は-1を返す
        }
        return marketStock[brandIndex];
    }

    // 各種ブランドの在庫ランキングを取得(インデックス = 順位, 値 = ブランドID)
    int[] getBrandRanking() {
        int[] rankings = new int[marketStock.length];
        for (int i = 0; i < marketStock.length; i++) {
            rankings[i] = i; // インデックスを順位として使用し、値をブランドIDとする
        }
        for (int i = 0; i < marketStock.length - 1; i++) {
          for (int j = 0; j < marketStock.length - 1 - i; j++) {
              // 在庫数を比較（降順）
              if (marketStock[rankings[j]] < marketStock[rankings[j + 1]]) {
                  // ブランドIDを交換
                  int temp = rankings[j];
                  rankings[j] = rankings[j + 1];
                  rankings[j + 1] = temp;
              }
          }
      }
        return rankings;
    }

    // ========== 市場の在庫を更新 ==========
    // ブランドの在庫を更新
    void updateBrandStock(int brandIndex, int changeAmount) {
        if (brandIndex < 0 || brandIndex >= marketStock.length) {
            return;
        }
        if (marketStock[brandIndex] + changeAmount < 0) {
            println("error: updateBrandStock()で在庫が負になろうとしています。");
            return; // 在庫が負にならないように制御
        }
        marketStock[brandIndex] += changeAmount;
    }
    
    // ========== 市場のアクション ==========
    // 出荷処理
    void ship(int[] brands) {
        // 在庫更新処理
        if (brands.length != marketStock.length) {
            println("受け取ったブランドの数が市場のブランド数と一致しません。");
            return;
        }
        // 各ブランドの在庫を更新
        // brandsはインデックスに対応するブランドの在庫数を表す
        for (int i=0; i < brands.length; i++) {
            int amount = brands[i];
            if (i < 0 || i >= marketStock.length) {
                println("無効なブランドインデックス: " + i);
                continue;
            }
            updateBrandStock(i, amount);
        } 
        // 在庫に応じて価値を更新
        updateBrandPoint();
    }

    // 利益計算
    int calculateProfit(int[] brands) {
        int profit = 0;
        for (int i=0; i<brands.length; i++) {
            if (i < 0 || i >= marketStock.length) {
                println("無効なブランドインデックス: " + i);
                continue;
            }
            profit += riceBrandsInfo[i].point * brands[i];
        }
        return profit;
    }

    // 市場の消費
    // ここでは、各ブランドの在庫をランダムに消費する
    void consume() {
        // まず、各ブランドの在庫を配列にidで格納
        int[] brandIds = new int[getTotalStock()];
        int index = 0;
        for (int i=0; i<marketStock.length; i++) {
            for (int j=0; j<marketStock[i]; j++) {
                brandIds[index++] = i; // ブランドのインデックスを格納
            }
        }
        // 配列をシャッフル
        shuffleArray(brandIds);

        // 消費数を決定
        int startCount = int(getTotalStock() * CONSUME_MIN_RATIO);
        int finishCount = int(getTotalStock() * CONSUME_MAX_RATIO);
        int consumeCount = int(random(startCount, finishCount));
        // consumeCountがbrandIds.lengthを超えないようにする
        consumeCount = min(consumeCount, brandIds.length);

        // 消費処理(配列の先頭からconsumeCount個を消費)
        for (int i=0; i<consumeCount; i++) {
            updateBrandStock(brandIds[i], -1); // 在庫を1減らす
        }
    }
    // 配列をシャッフルする関数
    void shuffleArray(int[] array) {
        for (int i = array.length - 1; i > 0; i--) {
            int j = int(random(i + 1));
            int temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    // 環境アクション(未定)
    void EnvironmentEffect(String effect) {
        currentEnvironment = effect;
        switch (effect) {
            case "豊作":
                break;
            case "不作":
                break;
            case "NORMAL":
                break;
            default:
                println("未知の環境効果: " + effect);
                break;
        }
    }

    // ブランド価格計算
    // 各ブランドの在庫に応じて価格を変動 BASE_CARD_POINTが基準
    // 一番在庫があるものはBASE_CARD_POINTの0.5倍、次に在庫があるものはBASE_CARD_POINTの1倍、残りは1.5倍
    void updateBrandPoint() {
        // 各ブランドの順位を格納する配列（1位、2位、3位...）
        int[] rankings = new int[marketStock.length];

        // 各ブランドの在庫数を確認して順位を決定
        for (int i = 0; i < marketStock.length; i++) {
            int rank = 1; // 初期順位は1位

            // 他のブランドと比較
            for (int j = 0; j < marketStock.length; j++) {
                if (i != j && marketStock[j] > marketStock[i]) {
                    rank++; // 自分より在庫が多いブランドがあれば順位を下げる
                }
            }

            rankings[i] = rank;
        }

        // 順位に基づいてポイントを更新
        for (int i = 0; i < marketStock.length; i++) {
            if (rankings[i] == 1) {
                // 1位（一番在庫が多い）
                riceBrandsInfo[i].point = int(BASE_CARD_POINT * 0.5);
            } else if (rankings[i] == 2) {
                // 2位（二番目に在庫が多い）
                riceBrandsInfo[i].point = BASE_CARD_POINT;
            } else {
                // 3位以下（その他）
                riceBrandsInfo[i].point = int(BASE_CARD_POINT * 1.5);
            }
        }
    }


    void environmentAction() {
    }
}