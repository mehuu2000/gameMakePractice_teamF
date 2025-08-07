// 出荷選択や手札戻し、利益描画などのポップアップの描画を管理するクラス
String[] riceOldInfo = {"新米", "古米", "古古米"};
class Popup {
  int yearPopupStartTime = 0;
  boolean yearPopupTimerSet = false;

  // ポップアップの種類を定義
  void drawPopup(String type) {
    switch(type) {
    case "year":
      drawYearPopup();
      break;
    case "carry":
      drawCarryPopup();
      break;
    case "cell":
      drawCellPopup();
      break;
    case "buy":
      drawBuyPopup();
      break;
    case "submit":
      drawSubmitPopup();
      break;
    case "return":
      drawReturnPopup();
      break;
    case "turnEnd":
      drawTurnEndPopup();
      break;
    case "countStart":
      drawCountStartPopup();
      break;
    case "fluctuation":
      drawFluctuationPopup();
      break;
    case "profit":
      drawProfitPopup();
      break;
    case "event":
      drawEventPopup();
      break;
    case "forecast":
      drawForecastPopup();
      break;
    default:
      // 何もしないか、エラーメッセージを表示
      break;
    }

    drawCloseButton();
  }

  // 年数ポップアップの描画
  void drawYearPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    fill(21, 96, 130);
    rect(width/2 - 250, height/2 - 100, 500, 200);

    textAlign(CENTER, CENTER);
    fill(250);
    textSize(120);
    text(currentTurn + "年目", width/2, height/2);

    fill(0);

    // このポップアップが表示されてから2秒後にshowPopup("buy")を呼び出す。
    if (elapsedTime >= 3000) {
      yearPopupTimerSet = false;
      closePopup();
      if (currentTurn == 1) {
        showPopup("carry");
      } else {
        showPopup("buy");
      }
    }
  }

  // 市場に持ち運ばれた米を表示するポップアップの描画
  void drawCarryPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    stroke(0);
    strokeWeight(2);

    fill(240);
    rect((width * 0.3) + 100, 100, (width * 0.7) - 200, height - 200);

    fill(0);
    textSize(40);
    textAlign(LEFT, CENTER);
    text("市場にお米が", (width * 0.3) + 200, 180);
    text("持ち運ばれました！", (width * 0.3) + 200, 230);
    textAlign(CENTER, CENTER);

    if (elapsedTime >= 2000) {
      yearPopupTimerSet = false;
      closePopup();
      showPopup("buy"); // 米購入のポップアップを表示
    }
  }

  // 米の購入による市場変動のポップアップの描画
  void drawCellPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    stroke(0);
    strokeWeight(2);

    fill(240);
    rect((width * 0.3) + 100, 100, (width * 0.7) - 200, height - 200);

    fill(0);
    textSize(40);
    textAlign(LEFT, CENTER);
    text("市場からお米が", (width * 0.3) + 200, 180);
    text("購入されました！", (width * 0.3) + 200, 230);
    textAlign(CENTER, CENTER);

    if (elapsedTime >= 2000) {
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  // 買い付けポップアップの描画
  void drawBuyPopup() {
    stroke(0);
    strokeWeight(2);

    fill(240);
    rect((width * 0.3) + 50, 70, (width * 0.7) - 100, height - 175);

    stroke(0);
    line((width * 0.3) + 50, height - 250, width - 52, height - 250);
    noStroke();

    fill(0);
    textSize(40);
    text("どのお米を購入しますか？", (width * 0.3) + 350, 130);

    // ブランド表示
    textAlign(LEFT, CENTER);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(255);
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      rect((width * 0.3) + 120, 210 + (i*60), 30, 45); // デモ用のカード
      fill(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      text(riceBrandsInfo[riceBrandRanking[i]].name, (width * 0.3) + 170, 230 + (i*60));
    }
    fill(0);
    noStroke();

    // 価格表示
    textAlign(RIGHT, CENTER);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      text(riceBrandsInfo[riceBrandRanking[i]].point + "pt", (width * 0.3) + 576, 230 + (i*60));
    }

    // 購入数表示
    textAlign(CENTER, CENTER);
    text("購入数", (width * 0.3) + 700, 170);
    for (int i=0; i<riceBrandsInfo.length; i++) {
        brandMinus1Buttons[i].display();
        text(selectedAmounts[riceBrandRanking[i]], (width * 0.3) + 700, 230 + (i*60));
        brandPlus1Buttons[i].display();
    }

    textSize(36);
    textAlign(RIGHT, CENTER);

    text("購入合計金額 ", (width * 0.3) + 350, height - 200);
    text(totalPrice + " pt", (width * 0.3) + 500, height - 200);

    text("購入後残金 ", (width * 0.3) + 350, height - 150);
    text((player.wallet - totalPrice) + " pt", (width * 0.3) + 500, height - 150);

    buyButton.display();

    textAlign(CENTER, CENTER);
  }

  // 提出ポップアップの描画
  void drawSubmitPopup() {
    gameState.handBrandCount(); // その時のブランドが手札に何枚あるかのsumBrandCountを更新 

    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 140, 70, (width * 0.7) - 190, height - 90);

    line((width * 0.3) + 140, height - 170, width - 52, height -170);
    noStroke();

    // デモカード
    fill(250);
    stroke(riceBrandsInfo[selectedBrandId].brandColor);
    strokeWeight(1);
    rect((width * 0.3) + 190, 230, 100, 180); //デモカード

    // ブランド名
    fill(riceBrandsInfo[selectedBrandId].brandColor);
    textSize(52);
    text(riceBrandsInfo[selectedBrandId].name, (width * 0.3) + 460, 330); //デモ

    // ブランド名 + を何枚提出しますか？
    textSize(40);
    textAlign(LEFT, CENTER);
    text(riceBrandsInfo[selectedBrandId].name, (width * 0.3) + 220, 140);
    fill(0);
    text("を何枚提出しますか？", (width * 0.3) + 220, 190);
    textAlign(CENTER, CENTER);

    // 提出数の選択 + ボタン
    minus1SelectedButton.display();
    fill(0);
    textSize(36);
    text(selectedAmounts[selectedBrandId], 1120, 312);
    plus1SelectedButton.display();

    fill(0);
    textSize(36);
    text("提出数", (width * 0.3) + 730, 250);
    for (int i=0; i<riceOldInfo.length; i++) {
      text(riceOldInfo[i], (width * 0.3) + 280+(i*150), height - 280);
      text(player.handRices[selectedBrandId][i], (width * 0.3) + 280+(i*150), height - 230);
    }
    text("総数", (width * 0.3) + 280+(3*150), height - 280);
    text(sumBrandCount, (width * 0.3) + 280+(3*150), height - 230);

    closePopupButton.display();
    loadButton.display();
    noStroke();
  }

  // 手札に戻すポップアップの描画
  void drawReturnPopup() {
    gameState.loadBrandCount(); // その時のブランドが手札に何枚あるかのsumBrandCountを更新
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 140, 70, (width * 0.7) - 190, height - 90);

    line((width * 0.3) + 140, height - 170, width - 52, height -170);
    noStroke();

    // デモカード
    fill(250);
    stroke(riceBrandsInfo[selectedBrandId].brandColor);
    strokeWeight(1);
    rect((width * 0.3) + 190, 230, 100, 180); //デモカード

    // ブランド名
    fill(riceBrandsInfo[selectedBrandId].brandColor);
    textSize(52);
    text(riceBrandsInfo[selectedBrandId].name, (width * 0.3) + 460, 330); //デモ

    // ブランド名 + を何枚提出しますか？
    textSize(40);
    textAlign(LEFT, CENTER);
    text(riceBrandsInfo[selectedBrandId].name, (width * 0.3) + 220, 140);
    fill(0);
    text("を何枚手札に戻しますか？", (width * 0.3) + 220, 190);
    textAlign(CENTER, CENTER);

    // 提出数の選択 + ボタン
    minus1SelectedButton.display();
    fill(0);
    textSize(36);
    text(selectedAmounts[selectedBrandId], 1120, 312);
    plus1SelectedButton.display();

    fill(0);
    textSize(36);
    text("返却数", (width * 0.3) + 730, 250);
    for (int i=0; i<riceOldInfo.length; i++) {
      text(riceOldInfo[i], (width * 0.3) + 280+(i*150), height - 280);
      text(player.loadRices[selectedBrandId][i], (width * 0.3) + 280+(i*150), height - 230);
    }
    text("総数", (width * 0.3) + 280+(3*150), height - 280);
    text(sumBrandCount, (width * 0.3) + 280+(3*150), height - 230);

    closePopupButton.display();
    returnButton.display();
    noStroke();    
  }

  // ターン終了ポップアップの描画
  void drawTurnEndPopup() {
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 160, (width * 0.7) - 190, height - 350);
    
    textAlign(LEFT, CENTER);
    fill(0);
    textSize(44);
    text("ターンを終了して", (width * 0.3) + 270, 250);
    text("よろしいですか？", (width * 0.3) + 270, 310);
    textAlign(CENTER, CENTER);
    
    closeEndPopupButton.display();
    turnEndButton.display();
    noStroke();
  }

  // 集計開始ポップアップの描画
  void drawCountStartPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    fill(21, 96, 130);
    rect(width/2 - 375, height/2 - 150, 750, 300);

    textAlign(CENTER, CENTER);
    fill(250);
    textSize(120);
    text("集計開始！", width/2, height/2);
    if (elapsedTime >= 2000) {
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  //米の出荷による市場変動のポップアップの描画
  void drawFluctuationPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 160, (width * 0.7) - 190, height - 320);
    
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(255);
      textSize(40);
      textAlign(LEFT, CENTER);
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      rect((width * 0.3) + 220, 300 + (i*60), 30, 45); // デモ用のカード
      fill(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      text(riceBrandsInfo[riceBrandRanking[i]].name, (width * 0.3) + 270, 320 + (i*60));
      fill(0);
      text(marketStockKeep[riceBrandRanking[i]] + "→" + market.marketStock[riceBrandRanking[i]], (width * 0.3) + 600, 320 + (i*60));
    }
    
    fill(0);
    textSize(40);
    text("集計結果", (width * 0.3) + 370, 210);
    
    textSize(36);
    text("枚数", (width * 0.3) + 600, 260);
    textAlign(CENTER, CENTER);

    noStroke();

    if (elapsedTime >= 2000) {
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  // 利益のポップアップのための描画
  void drawProfitPopup() {
  }

  // イベントポップアップの描画
  void drawEventPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    Event currentEvent = eventManager.getCurrentEvent();
    if (currentEvent == null) return;
    
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 160, (width * 0.7) - 190, height - 320);
    
    fill(0);
    textSize(48);
    text("イベント発生！", (width * 0.3) + 370, 220);
    
    // イベント名
    textSize(40);
    fill(255, 0, 0);
    text(currentEvent.eventName, (width * 0.3) + 370, 300);
    
    // イベント効果説明
    fill(0);
    textSize(28);
    text(currentEvent.effectDescription, (width * 0.3) + 370, 380);
    
    // 持続時間
    if (currentEvent.duration > 1) {
      textSize(24);
      fill(100);
      text("（" + currentEvent.duration + "ターン持続）", (width * 0.3) + 370, 430);
    }
    
    noStroke();
    if (elapsedTime >= 2000) {
      yearPopupTimerSet = false;
      closePopup();
    }
  }
  
  // 予報ポップアップの描画
  void drawForecastPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    ForecastInfo forecast = eventManager.getCurrentForecast();
    if (forecast == null) return;
    
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 160, (width * 0.7) - 190, height - 320);
    
    fill(0);
    textSize(48);
    text("予報", (width * 0.3) + 370, 220);
    
    // 予報メッセージ
    textSize(32);
    fill(0, 0, 200);
    text(forecast.message, (width * 0.3) + 370, 320);
    
    // 注意書き
    textSize(20);
    fill(100);
    text("※予報は外れることがあります", (width * 0.3) + 370, 400);
    
    noStroke();

    if (elapsedTime >= 2000) {
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  // ポップアップを閉じるためのボタン描画
  void drawCloseButton() {
  }
}
