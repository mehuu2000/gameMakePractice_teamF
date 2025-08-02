// 右側のパネルを描画するクラス
class RightPanel {
    // 右側のパネル全体管理
    void drawRightPanel(){
        float rightX = width * 0.3;
        float rightWidth = width * 0.7;

        // 背景
        fill(250);
        rect(rightX, 0, rightWidth, height);
        
        fill(0);
        textAlign(CENTER);
        textSize(20);
        text("出荷準備など", rightX + rightWidth/2, height/2);
    }

    /* 以下は実装例 */

    // ターン数表示
    void drawTurnInfo(int turn) {}

    // 所持金表示
    void drawMoneyInfo(int money) {}

    // 出荷準備エリア
    void drawShippingArea() {}
    // AI出荷準備エリア
    void drawAIShippingArea() {}

    // 手札の描画
    void drawHandCards() {}
}
