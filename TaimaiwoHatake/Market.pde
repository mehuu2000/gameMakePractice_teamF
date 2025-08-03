// 市場の処理などを行うクラス
class Market {
    // ========== 市場在庫管理 ==========
    int [] marketStock;  //インデックス = 0: りょうおもい, 1: ほしひかり, 2:ゆめごこち, 3:つやおうじ | 値 = 在庫数

    // ========== 供給管理 ==========
    int supplyLimit;         // 供給上限

    // ========== 環境効果 ==========
    String currentEnvironment;  // 現在の環境（豊作、不作など）

    enum Environment {
        NORMAL,  // 通常
    }

    Market(int initBrandStock, int initSupplyLimit) {
        marketStock = new int[4] {0}; // 4つのブランドの在庫
        supplyLimit = initSupplyLimit; // 供給上限を設定
        currentEnvironment = Environment.NORMAL;
        initStockGeneration(initBrandStock);
    }

    void initStockGeneration(int initBrandStock) {
        for (int i=0; i<initBrandStock; i++) {
            // ランダムでインデックスを選択
            int brandIndex = int(random(0, marketStock.length));
            marketStock[brandIndex]++;
        }
    }

    // ========== 市場の情報を取得 ==========
    int getTotalStock() {
        int total = 0;
        for (int stock : marketStock) {
            total += stock;
        }
        return total;
    }

    int getBrandStock(int brandIndex) {
        if (brandIndex < 0 || brandIndex >= marketStock.length) {
            return -1; // 無効なインデックスの場合は-1を返す
        }
        return marketStock[brandIndex];
    }


    void marketAction() {
    }
    void environmentAction() {
    }
}