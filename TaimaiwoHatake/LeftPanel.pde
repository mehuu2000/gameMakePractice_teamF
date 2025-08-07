// 左側の市場を描画するクラス
class LeftPanel {
  UI ui;
  // コンストラクタ
  LeftPanel(UI ui) {
    this.ui = ui;
  }
  // 左側のパネル全体管理
  void drawLeftPanel() {
    fill(250);
    rect(0, 0, width * 0.3, height);

    textAlign(CENTER);

    drawMarketInfo();
    drawSupply();
    drawEnvironment();
  }

  /* 以下は実装例 */

  // 市場の情報を描画
  void drawMarketInfo() {
    fill(240);
    rect(10, 10, (width * 0.3) - 20, height/2);

    fill(0);
    textSize(48);
    text("市場", 90, 50);
    
    textSize(48);
    fill(255, 0, 0);
    text(ui.supplyLimitX + " ～ " + (ui.supplyLimitX + 10), 250, 50);
  }

  // 供給量の描画
  void drawSupply() {
    fill(0);
    textSize(24);
    strokeWeight(2);
    textAlign(CENTER, CENTER);
    text("枚数", 66, 100);

    // ブランドのカード (デモ用)
    fill(250);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      rect(15, 130 + (i * 60), 30, 45); // デモ用のカード
    }
    stroke(0);
    
    // ×の描画
    fill(0);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      textSize(28);
      text("×", 60, 150 + (i * 60));
    }

    // 供給数の描画
    for (int i=0; i<riceBrandsInfo.length; i++) {
      text(market.marketStock[riceBrandRanking[i]], 95, 151 + (i * 60));
    }

    // ブランド名の描画
    text("品種名", 205, 100);
    for (int i=0; i<riceBrandsInfo.length; i++) {
        text(riceBrandsInfo[riceBrandRanking[i]].name, 205, 152 + (i * 60));
    }

    // ブランドの価値の描画
    textSize(24);
    text("価値", (width * 0.3) - 50, 100);
    textAlign(RIGHT, CENTER);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      text(riceBrandsInfo[riceBrandRanking[i]].point + "pt", (width * 0.3) - 20, 151 + (i * 60));
    }

    textAlign(CENTER, CENTER);
    noStroke();
  }

  // 環境の描画
  void drawEnvironment() {
    fill(240);
    rect(10, height/2 + 20, (width * 0.3) - 20, height/2 - 30);
    
    fill(0);
    textSize(56);
    text("効果名", (width*0.3)/2, 410);
    
    rect(20, height/2 + 80, (width * 0.3) - 40, height/2 - 100);
    
    fill(240);
    rect(23, height/2 + 83, (width * 0.3) - 46, height/2 - 106);
  }
}
