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
    
    // 現在のイベントを取得
    Event currentEvent = null;
    String eventName = "通常";
    String eventMessage = "";
    int remainingTurns = 0;
    
    if (eventManager != null) {
      currentEvent = eventManager.getCurrentEvent();
      if (currentEvent != null) {
        eventName = currentEvent.eventName;
        eventMessage = currentEvent.effectMessage;
        remainingTurns = eventManager.activeEventRemainingTurns;
      }
    }
    
    // イベント名の表示
    fill(0);
    if (currentEvent != null && !eventName.equals("通常")) {
      fill(200, 0, 0); // イベント発動中は赤色
    } else {
      fill(0);
    }

    textSize(36);
    text(eventName, (width*0.3)/2, 420);
    
    // 効果説明のエリア
    fill(0);
    rect(20, height/2 + 100, (width * 0.3) - 40, height/2 - 120);
    
    fill(240);
    rect(23, height/2 + 103, (width * 0.3) - 46, height/2 - 126);
    
    // 効果の説明文（ゲームへの影響）
    fill(0);
    textSize(20);
    textAlign(CENTER, CENTER);
    if (!eventMessage.isEmpty()) {
      text(eventMessage, (width*0.3)/2, height - 130);
    } else {
      text("特別な効果なし", (width*0.3)/2, height - 130);
    }
    
    // 残りターン数の表示（イベントが有効な場合）
    if (currentEvent != null && remainingTurns > 0 && !eventName.equals("通常")) {
      textAlign(CENTER, CENTER);
      textSize(20);
      fill(100);
      text("残り " + remainingTurns + " ターン", (width*0.3)/2, height - 50);
    }
    
    textAlign(CENTER, CENTER);
  }
}
