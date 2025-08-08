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
    case "news":
      drawNewsPopup();
      break;
    case "missed":
      drawMissedPopup();
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
    stroke(0);
    strokeWeight(2);
    rect(width/2 - 280, height/2 - 100, 580, 200);

    textAlign(CENTER, CENTER);
    fill(250);
    textSize(120);
    text(currentYear_season[0] + "年目：" + SEASONS[currentYear_season[1]], width/2, height/2);

    fill(0);
    noStroke();

    // 1ターン目の場合、表示してから2秒後にcarryポップアップを表示
    if (elapsedTime >= 2000) {
      yearPopupTimerSet = false;
      closePopup();
      if (currentTurn == 1) {
        showPopup("carry");
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
    
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(255);
      textSize(44);
      textAlign(LEFT, CENTER);
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      rect((width * 0.3) + 220, 320 + (i*60), 30, 45); // デモ用のカード
      fill(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      text(riceBrandsInfo[riceBrandRanking[i]].name, (width * 0.3) + 270, 340 + (i*60));
      fill(0);
      textAlign(CENTER, CENTER);
      text(market.marketStock[riceBrandRanking[i]], (width * 0.3) + 630, 340 + (i*60));
      
      //持ち運ばれたタイミングの価格を保存
      marketPriceKeep[riceBrandRanking[i]] = riceBrandsInfo[riceBrandRanking[i]].point;
    }
    
    textSize(36);
    text("枚数", (width * 0.3) + 630, 280);

    noStroke();

    if (elapsedTime >= 3000) {
      yearPopupTimerSet = false;
      closePopup();
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
    
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(255);
      textSize(44);
      textAlign(LEFT, CENTER);
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      rect((width * 0.3) + 220, 300 + (i*60), 30, 45); // デモ用のカード
      fill(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      text(riceBrandsInfo[riceBrandRanking[i]].name, (width * 0.3) + 270, 320 + (i*60));
      fill(0);
      text(marketStockAfterShip[riceBrandRanking[i]] + "→" + market.marketStock[riceBrandRanking[i]], (width * 0.3) + 600, 320 + (i*60));
      
      //米を購入されたタイミングの価格を保存
      marketPriceKeep[riceBrandRanking[i]] = riceBrandsInfo[riceBrandRanking[i]].point;
    }
    
    textSize(36);
    text("枚数", (width * 0.3) + 610, 260);
    textAlign(CENTER, CENTER);

    noStroke();

    if (elapsedTime >= 3000) {
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

    // 価格表示（EventEffectの効果を適用）
    textAlign(RIGHT, CENTER);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      float effectMultiplier = 1.0;
      if (effectManager != null) {
        effectMultiplier = effectManager.getBrandBuyPriceMultiplier(riceBrandRanking[i]);
      }
      text(int(riceBrandsInfo[riceBrandRanking[i]].point * RICE_BUY_RATIO * effectMultiplier) + "pt", (width * 0.3) + 576, 230 + (i*60));
    }

    // 購入数表示
    textAlign(CENTER, CENTER);
    text("購入数", (width * 0.3) + 700, 170);
    
    // 仕入れ量倍率を取得
    float supplyMultiplier = 1.0;
    if (effectManager != null) {
      supplyMultiplier = effectManager.getSupplyMultiplier();
    }
    
    for (int i=0; i<riceBrandsInfo.length; i++) {
        brandMinus1Buttons[i].display();
        int displayAmount = selectedAmounts[riceBrandRanking[i]];
        
        // 仕入れ量倍率が1.0以外の場合は実際の取得量も表示
        if (supplyMultiplier != 1.0 && displayAmount > 0) {
          float rawAmount = displayAmount * supplyMultiplier;
          int actualAmount;
          
          if (supplyMultiplier < 1.0) {
            // 減少時（台風など）は切り上げ（最小1枚を保証）
            actualAmount = (int)Math.ceil(rawAmount);
            if (actualAmount < 1) {
              actualAmount = 1;
            }
          } else {
            // 増加時（大盤振米など）も切り上げ
            actualAmount = (int)Math.ceil(rawAmount);
          }
          textSize(20);
          text(displayAmount + "→" + actualAmount, (width * 0.3) + 700, 230 + (i*60));
          textSize(36);
        } else {
          text(displayAmount, (width * 0.3) + 700, 230 + (i*60));
        }
        
        brandPlus1Buttons[i].display();
    }

    textSize(36);
    textAlign(RIGHT, CENTER);

    text("購入合計金額 ", (width * 0.3) + 350, height - 200);
    text(totalPrice + " pt", (width * 0.3) + 500, height - 200);

    text("購入後残金 ", (width * 0.3) + 350, height - 150);
    text((player.wallet - totalPrice) + " pt", (width * 0.3) + 500, height - 150);

    buyButton.display();
    closeBuyPopupButton.display();

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
    rect((width * 0.3) + 190, 230, 120, 180); //デモカード

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
      text(marketStockKeep[riceBrandRanking[i]] + "→" + marketStockAfterShip[riceBrandRanking[i]], (width * 0.3) + 600, 320 + (i*60));
    }
    
    fill(0);
    textSize(40);
    text("集計結果", (width * 0.3) + 370, 210);
    
    textSize(36);
    text("枚数", (width * 0.3) + 600, 260);
    textAlign(CENTER, CENTER);

    noStroke();

    if (elapsedTime >= 3000) {
      ses[4].play();
      ses[4].rewind();
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  // 利益のポップアップのための描画
  void drawProfitPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 160, (width * 0.7) - 190, height - 270);
    
    for (int i=0; i<riceBrandsInfo.length; i++) { //カード情報の表示
      fill(255);
      textSize(40);
      textAlign(LEFT, CENTER);
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      rect((width * 0.3) + 130, 300 + (i*60), 30, 45); // デモ用のカード
      fill(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      text(riceBrandsInfo[riceBrandRanking[i]].name, (width * 0.3) + 180, 320 + (i*60));
      fill(0);
      text(playerLoadedRices[riceBrandRanking[i]], (width * 0.3) + 610, 320 + (i*60));
      text(aiLoadedRices[riceBrandRanking[i]], (width * 0.3) + 730, 320 + (i*60));
      
      textAlign(RIGHT, CENTER);
      if((marketPriceKeep[riceBrandRanking[i]] - riceBrandsInfo[riceBrandRanking[i]].point) > 0){
        fill(255, 0, 0); // 価値が下がったら赤字にする
      }
      text(riceBrandsInfo[riceBrandRanking[i]].point + "pt", (width * 0.3) + 550, 320 + (i*60));
      fill(0);
    }
    
    // プレイヤーと敵の総利益
    text(playerProfit + "pt", (width * 0.3) + 650, 570);
    text(aiProfit + "pt", (width * 0.3) + 800, 570);
    
    textAlign(LEFT, CENTER);
    fill(0);
    textSize(40);
    text("集計結果", (width * 0.3) + 370, 210);
    text("合計", (width * 0.3) + 420, 570);
    
    textSize(32);
    text("価値", (width * 0.3) + 470, 260);
    
    fill(0, 112, 192);
    text("あなた", (width * 0.3) + 570, 260);
    fill(192, 0, 0);
    text("あいて", (width * 0.3) + 690, 260);
    textAlign(CENTER, CENTER);
    fill(0);

    noStroke();

    if (elapsedTime >= 5000) {
      yearPopupTimerSet = false;
      closePopup();
    }
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
    textSize(40);
    text("イベントが発生しました！", (width * 0.3) + 460, 210);
    
    // イベント名
    textAlign(CENTER, TOP);
    text("【" + currentEvent.eventName + "】", (width * 0.3) + 460, 280);

    // イベントの説明（なぜ起こったか）
    textSize(26);
    textAlign(LEFT, TOP);
    text(currentEvent.effectDescription, (width * 0.3) + 190, 340, (width * 0.7) - 350, 200);
    
    // 持続時間
    // if (currentEvent.duration > 1) {
    //   textSize(24);
    //   fill(100);
    //   text("（" + currentEvent.duration + "ターン持続）", (width * 0.3) + 370, 430);
    // }
    
    textAlign(CENTER, CENTER);  // 他の箇所のためにリセット
    noStroke();
    if (elapsedTime >= 5000) {
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  // 予報ポップアップの描画
  void drawNewsPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    // 全ての予報を取得
    ArrayList<ForecastInfo> allForecasts = eventManager.getAllCurrentForecasts();
    if (allForecasts == null || allForecasts.size() == 0) return;
    
    // どの予報を表示するか決定（時間経過で切り替え）
    int displayTime = 3000; // 各予報を3秒表示
    int currentForecastIndex = (elapsedTime / displayTime) % allForecasts.size();
    ForecastInfo forecast = allForecasts.get(currentForecastIndex);
    
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 160, (width * 0.7) - 190, height - 320);
    rect((width * 0.3) + 150, 200, (width * 0.7) - 270, height - 400);
    
    noStroke();
    fill(240);
    rect((width * 0.3) + 400, 180, 120, 40);
    
    fill(0);
    textSize(44);
    text("予報", (width * 0.3) + 460, 200);
    
    // 複数予報がある場合は番号を表示
    if (allForecasts.size() > 1) {
      textSize(24);
      fill(100);
      text((currentForecastIndex + 1) + " / " + allForecasts.size(), (width * 0.3) + 460, 240);
    }
    
    // 予報の内容をここに記述
    fill(0);
    textSize(28);
    textAlign(LEFT, TOP);
    text(forecast.message, (width * 0.3) + 200, 290, (width * 0.7) - 370, 220);
    
    textAlign(CENTER, CENTER);

    // 全ての予報を一巡したら閉じる
    if (elapsedTime >= displayTime * allForecasts.size()) {
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  // 予報外れポップアップの描画
  void drawMissedPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    Event dummyEvent = eventManager.getCurrentDummyEvent();
    if (dummyEvent == null) return;
    
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 160, (width * 0.7) - 190, height - 320);
    rect((width * 0.3) + 150, 200, (width * 0.7) - 270, height - 400);
    
    noStroke();
    fill(240);
    rect((width * 0.3) + 400, 180, 120, 40);
    
    fill(0);
    textSize(44);
    text("速報", (width * 0.3) + 460, 200);
    
    // 予報内容と外れメッセージを表示
    fill(0);
    textSize(24);
    textAlign(LEFT, TOP);
    // 予報内容を先に表示
    String fullMessage = "【予報】" + dummyEvent.forecastMessage + "\n\n" + 
                        "【結果】" + dummyEvent.missedMessage;
    text(fullMessage, (width * 0.3) + 180, 270, (width * 0.7) - 300, 250);
    
    textAlign(CENTER, CENTER);

    if (elapsedTime >= 4000) {  // 内容が増えたので表示時間を延長
      yearPopupTimerSet = false;
      closePopup();
    }
  }

  // ポップアップを閉じるためのボタン描画
  void drawCloseButton() {
  }
}
