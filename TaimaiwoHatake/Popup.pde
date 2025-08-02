// 出荷選択や手札戻し、利益描画などのポップアップの描画を管理するクラス
class Popup {
    /* 以下は実装例 */

    // ポップアップの種類を定義
    void drawPopup(String type) {
        switch(type) {
            case "buy":
                drawBuyPopup();
                break;
            case "ship":
                drawShipPopup();
                break;
            case "return":
                drawReturnPopup();
                break;
            case "profit":
                drawProfitPopup();
                break;
            default:
                // 何もしないか、エラーメッセージを表示
                break;
        }
        drawCloseButton();
    }

    // 買い付けポップアップの描画
    void drawBuyPopup() {}
    
    // 出荷ポップアップの描画
    void drawShipPopup() {}

    // 手札に戻すポップアップの描画
    void drawReturnPopup() {}

    // ポップアップを閉じるためのボタン描画
    void drawCloseButton() {}

    // 利益のポップアップのための描画
    void drawProfitPopup() {}
}