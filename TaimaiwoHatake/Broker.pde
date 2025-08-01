// 右側のゲーム状態を管理するクラス
class Broker {
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
}