// 左側の市場を描画するクラス
class LeftPanel {
    // 左側のパネル全体管理
    void drawLeftPanel() {
        fill(200);
        rect(0, 0, width * 0.3, height);

        fill(0);
        textAlign(CENTER);
        textSize(20);
        text("市場情報", (width*0.3)/2, height/2);
    }

    /* 以下は実装例 */

    // 市場の情報を描画
    void drawMarketInfo() {}

    // 供給量の描画
    void drawSupply() {}

    // 環境の描画
    void drawEnvironment() {}


}