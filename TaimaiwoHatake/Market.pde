// 左側の市場を管理するクラス
class Market {
    void drawLeftPanel() {
        fill(200);
        rect(0, 0, width * 0.3, height);

        fill(0);
        textAlign(CENTER);
        textSize(20);
        text("市場情報", (width*0.3)/2, height/2);
    }
}