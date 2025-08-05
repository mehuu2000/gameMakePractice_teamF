// 右側のパネルを描画するクラス
class RightPanel {
  // 右側のパネル全体管理
  void drawRightPanel() {
    float rightX = width * 0.3;
    float rightWidth = width * 0.7;

    // 背景
    fill(250);
    rect(rightX, 0, rightWidth, height);

    textAlign(CENTER);

    stroke(0);
    strokeWeight(5);
    line(width * 0.3 + 5, 0, width * 0.3 + 5, height);
  }

  /* 以下は実装例 */

  // ターン数表示
  void drawTurnInfo(int currentTurn) {
    noStroke();
    fill(21, 96, 130);
    rect(1110, 20, 150, 60);

    fill(0);
    textSize(40);
    text(currentTurn + "年目", 1190, 65);
  }

  // 所持金表示
  void drawPointInfo() {
    fill(21, 96, 130);
    rect(width * 0.3 + 20, 20, 120, 100);

    fill(255);
    textSize(30);
    text("所持金", width * 0.3 + 80, 60);
    text(ENEMY_POINT + "pt", width * 0.3 + 80, 100);

    fill(240);
    rect(width * 0.3 + 20, height - 120, 120, 100);

    fill(21, 96, 130);
    text("所持金", width * 0.3 + 80, height - 80);
    text(PLAYER_POINT + "pt", width * 0.3 + 80, height - 40);
  }

  // 出荷準備エリア
  void drawShippingArea() {
    fill(100);
    rect(width * 0.3 + 100, 280, 710, 140);
  }
  // AI出荷準備エリア
  void drawAIShippingArea() {
    fill(255, 0, 0);
    rect(width * 0.3 + 100, 130, 710, 140);
  }

  // 手札の描画
  void drawHandCards() {
  }
}
