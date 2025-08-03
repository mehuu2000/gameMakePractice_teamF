// 市場の処理などを行うクラス
class Market {
    // ========== 市場在庫管理 ==========
    int [] marketStock;  //インデックス = 0: りょうおもい, 1: ほしひかり, 2:ゆめごこち, 3:つやおうじ | 値 = 在庫数

    // ========== 供給管理 ==========
    int supplyLimit;         // 供給上限

    // ========== 環境効果 ==========
    String currentEnvironment;  // 現在の環境（豊作、不作など)

    Market() {
        marketStock = new int[4]; // 4つのブランドの在庫
        setSupplyLimit(); // 供給上限を設定
        initStockGeneration(supplyLimit); // 初期在庫を生成
        currentEnvironment = "NORMAL"; // 初期環境は通常
    }

    // ========== 市場在庫の初期化 ==========
    // 初期供給上限を50-100の間でランダムに生成
    void setSupplyLimit() {
        supplyLimit = int(random(50, 101));
    }

    // 初期のブランド在庫を設定
    // ここでは、各ブランドの初期在庫を供給上限を参考にして設定
    void initStockGeneration(int supplyLimit) {
        int startCount = supplyLimit/4;
        int finishCount = supplyLimit/4 * 3;
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

    // ========== 市場の在庫を更新 ==========
    // ブランドの在庫を更新
    void updateBrandStock(int brandIndex, int changeAmount) {
        if (brandIndex < 0 || brandIndex >= marketStock.length) {
            return;
        }
        if(marketStock[brandIndex] + changeAmount < 0) {
            println("error: updateBrandStock()で在庫が負になろうとしています。");
            return; // 在庫が負にならないように制御
        }
        marketStock[brandIndex] += changeAmount;
    }
    
    // ========== 市場のアクション ==========
    // 出荷処理
    void ship(int[] brands) {
        if (brands.length != marketStock.length) {
            println("受け取ったブランドの数が市場のブランド数と一致しません。");
            return;
        }
        // 各ブランドの在庫を更新
        // brandsはインデックスに対応するブランドの在庫数を表す
        for (int i=0; i < brands.length; i++) {
            int brandIndex = i;
            int amount = brands[i];
            if (brandIndex < 0 || brandIndex >= marketStock.length) {
                println("無効なブランドインデックス: " + brandIndex);
                continue;
            }
            updateBrandStock(brandIndex, amount);
        }
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
        int startCount = int(getTotalStock() * 0.2); // 20%を消費
        int finishCount = int(getTotalStock() * 0.6); // 60%を消費
        int consumeCount = int(random(startCount, finishCount)); // 全体数の2割から6割の間でランダムに消費数を決定

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

    // 利益計算

    // ブランド価格計算

    void marketAction() {
    }
    void environmentAction() {
    }
}