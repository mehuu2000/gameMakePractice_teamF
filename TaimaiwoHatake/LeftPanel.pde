// 左側の市場を描画するクラス
class LeftPanel {
  UI ui;
  // コンストラクタ
  LeftPanel(UI ui) {
    this.ui = ui;
  }
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
  void drawMarketInfo() {
    fill(240);
    rect(10, 10, (width * 0.3) - 20, height/2);

    fill(0);
    textSize(48);
    text("市場", 90, 50);
  }

  // 供給量の描画
  void drawSupply() {
  }

  // 環境の描画
  void drawEnvironment() {
    fill(240);
    rect(10, height/2 + 20, (width * 0.3) - 20, height/2 - 30);
    
    textSize(56);
    text("効果名", (width*0.3)/2, 430);
    
    textSize(48);
    fill(255, 0, 0);
    text(ui.supplyLimitX + " ～ " + (ui.supplyLimitX + 10), 250, 50);
  }
}
