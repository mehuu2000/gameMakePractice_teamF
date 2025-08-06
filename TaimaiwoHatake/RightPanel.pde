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

    drawTurnInfo();
    drawPointInfo();
    drawShippingArea();
    drawAIShippingArea();
    drawHandCards();
    drawButtons();
  }

  /* 以下は実装例 */

  // ターン数表示
  void drawTurnInfo() {
    stroke(21, 96, 130);
    strokeWeight(3);
    fill(250);
    rect(1133, -3, 150, 60, 0, 0, 0, 40);

    fill(21, 96, 130);
    textSize(40);
    text(currentTurn + "年目", 1213, 42);

    noStroke();
    fill(0);
  }

  // 所持金表示
  void drawPointInfo() {
    fill(21, 96, 130);
    rect(width * 0.3 + 20, 20, 120, 100);

    fill(255);
    textSize(30);
    text("所持金", width * 0.3 + 80, 60);
    text(ai.wallet + "pt", width * 0.3 + 80, 100);

    fill(240);
    rect(width * 0.3 + 20, height - 120, 120, 100);

    fill(21, 96, 130);
    text("所持金", width * 0.3 + 80, height - 80);
    text(player.wallet + "pt", width * 0.3 + 80, height - 40);
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
    strokeWeight(1);

    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(250);
      stroke(0);
      int brandCount = player.getSumHandRice(i);
      stroke(riceBrandsInfo[i].brandColor);

      // 個数分重ねて描画(少しずらす)
      if (brandCount > 0) {
        for (int j=min(brandCount, 5); j>0; j--) {
            rect((width * 0.3) + 160 + (140 * i) + (j * 3), height/2 + 120 - (j * 2), 120, 200, 10);
        }
      } else {
        rect((width * 0.3) + 160 + (140 * i), height/2 + 120, 120, 200, 10);
      }

      // 個数を表示するための下地
      noStroke();
      fill(21, 96, 130);
      ellipse((width * 0.3) + 160 + (140 * i) + 120, height/2 + 120, 30, 30);
      textAlign(CENTER, CENTER);
      fill(250);
      textSize(20);
      text(brandCount, (width * 0.3) + 160 + (140 * i) + 120, height/2 + 119);
    }

    noStroke();
    fill(0);
  }

  boolean onBrand1Clicked() {
    // 当たり判定をチェック
    if (mouseX > (width * 0.3) + 160 && mouseX < (width * 0.3) + 280 &&
        mouseY > height/2 + 120 && mouseY < height/2 + 320) {
      selectedBrandId = 0;
      showPopup("submit");
      return true;
    } else if (mouseX > (width * 0.3) + 300 && mouseX < (width * 0.3) + 420 &&
               mouseY > height/2 + 120 && mouseY < height/2 + 320) {
      selectedBrandId = 1;
      showPopup("submit");
      return true;
    } else if (mouseX > (width * 0.3) + 440 && mouseX < (width * 0.3) + 560 &&
               mouseY > height/2 + 120 && mouseY < height/2 + 320) {
      selectedBrandId = 2;
      showPopup("submit");
      return true;
    } else if (mouseX > (width * 0.3) + 580 && mouseX < (width * 0.3) + 700 &&
               mouseY > height/2 + 120 && mouseY < height/2 + 320) {
      selectedBrandId = 3;
      showPopup("submit");
      return true;
    }

    return false;
  }

  void drawButtons() {
    playDescribeButton.display();
    submitButton.display();
  }
}
