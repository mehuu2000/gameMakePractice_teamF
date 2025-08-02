// ゲーム画面のUIを管理するクラス

class UI {
    void draw_UHO(int textFlag) {
        fill(0);
        if (textFlag == 0) {
            textSize(100);
            text("ボタンを押せ！！！！！", width/2, height/2);
        } else if (textFlag == 1) {
            textSize(300);
            text("うほ", width/2, height/2);
        }
    }

    // スタート画面の描画
    void drawStartScreen(int playerPoint, int aiPoint) {}

    // 結果画面の描画
    void drawResultScreen() {}

    // 操作説明の描画
    // ここでは操作方法やルールを表示する
    // 例えば、ゲームの目的や操作方法などを説明する
    void drawInstructions() {}
}