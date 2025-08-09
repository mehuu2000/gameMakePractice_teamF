// 出荷選択や手札戻し、利益描画などのポップアップの描画を管理するクラス
String[] riceOldInfo = {"新米", "古米", "古古米"};
class Popup {
  int yearPopupStartTime = 0;
  boolean yearPopupTimerSet = false;
  boolean popupClosing = false;  // ポップアップが閉じる処理中フラグ
  int currentNewsIndex = 0;  // 現在表示中の予報のインデックス
  int seconds = 300;

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
    case "eventHistory":
      drawEventHistoryPopup();
      break;
    case "forecastHistory":
      drawForecastHistoryPopup();
      break;
    default:
      // 何もしないか、エラーメッセージを表示
      break;
    }

    drawCloseButton();
    cardVisual.loadCardImages();
  }

  // 年数ポップアップの描画
  void drawYearPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        popupClosing = false;  // フラグをリセット
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

    // 表示してから2秒後に閉じる
    if (elapsedTime >= 2000 && !popupClosing) {
      popupClosing = true;  // 閉じる処理を開始
      closePopup();
    }
  }

  // 市場に持ち運ばれた米を表示するポップアップの描画
  void drawCarryPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        nextButton.isEnabled = false;  // 最初はボタンを無効化
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
      image(cardVisual.cardImages[riceBrandRanking[i]], (width * 0.3) + 220, 320 + (i*60), 30, 45); // デモ用のカード
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

    // ボタンは常に表示
    nextButton.display();
    
    // 1秒後にボタンを有効化
    if (elapsedTime >= seconds) {
      nextButton.isEnabled = true;
    }
  }

  // 米の購入による市場変動のポップアップの描画
  void drawCellPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        nextButton.isEnabled = false;  // 最初はボタンを無効化
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
      image(cardVisual.cardImages[riceBrandRanking[i]], (width * 0.3) + 220, 300 + (i*60), 30, 45); // デモ用のカード
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

    // ボタンは常に表示
    nextButton.display();
    
    // 1秒後にボタンを有効化
    if (elapsedTime >= seconds) {
      nextButton.isEnabled = true;
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
    text("どのお米を仕入れますか？", (width * 0.3) + 350, 130);

    // ブランド表示
    textAlign(LEFT, CENTER);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(255);
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      image(cardVisual.cardImages[riceBrandRanking[i]],(width * 0.3) + 120, 210 + (i*60), 30, 45); // デモ用のカード
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
    text("仕入数", (width * 0.3) + 700, 170);
    
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
    image(cardVisual.cardImages[selectedBrandId], (width * 0.3) + 190, 230, 120, 180); //デモカード

    // ブランド名
    fill(riceBrandsInfo[selectedBrandId].brandColor);
    textSize(52);
    text(riceBrandsInfo[selectedBrandId].name, (width * 0.3) + 460, 330); //デモ

    // ブランド名 + を何枚提出しますか？
    textSize(40);
    textAlign(LEFT, CENTER);
    text(riceBrandsInfo[selectedBrandId].name, (width * 0.3) + 220, 140);
    fill(0);
    text("を何枚トラックに積みますか？", (width * 0.3) + 220, 190);
    textAlign(CENTER, CENTER);

    // 提出数の選択 + ボタン
    minus1SelectedButton.display();
    fill(0);
    textSize(36);
    text(selectedAmounts[selectedBrandId], 1120, 312);
    plus1SelectedButton.display();

    fill(0);
    textSize(36);
    text("積載数", (width * 0.3) + 730, 250);
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
    image(cardVisual.cardImages[selectedBrandId], (width * 0.3) + 190, 230, 120, 180); //デモカード

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
        popupClosing = false;  // フラグをリセット
    }
    int elapsedTime = millis() - yearPopupStartTime;

    fill(21, 96, 130);
    rect(width/2 - 375, height/2 - 150, 750, 300);

    textAlign(CENTER, CENTER);
    fill(250);
    textSize(120);
    text("集計開始！", width/2, height/2);
    
    if (elapsedTime >= 2000 && !popupClosing) {
      popupClosing = true;  // 閉じる処理を開始
      closePopup();
    }
  }

  //米の出荷による市場変動のポップアップの描画
  void drawFluctuationPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        nextButton.isEnabled = false;  // 最初はボタンを無効化
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
      image(cardVisual.cardImages[riceBrandRanking[i]], (width * 0.3) + 220, 300 + (i*60), 30, 45); // デモ用のカード
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

    // ボタンは常に表示
    nextButton.display();
    
    // 1秒後にボタンを有効化
    if (elapsedTime >= seconds) {
      nextButton.isEnabled = true;
    }
  }

  // 利益のポップアップのための描画
  void drawProfitPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        nextButton.isEnabled = false;  // 最初はボタンを無効化
        // 利益表示と同時にお金の効果音を再生
        ses[4].play();
        ses[4].rewind();
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
      image(cardVisual.cardImages[riceBrandRanking[i]], (width * 0.3) + 130, 300 + (i*60), 30, 45); // デモ用のカード
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

    // ボタンは常に表示
    nextButton.display();
    
    // 1秒後にボタンを有効化
    if (elapsedTime >= seconds) {
      nextButton.isEnabled = true;
    }
  }

  // イベントポップアップの描画
  void drawEventPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        nextButton.isEnabled = false;  // 最初はボタンを無効化
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
    if (elapsedTime >= seconds) {
      nextButton.isEnabled = true;  // ボタンを有効化
      nextButton.display();
    }
  }

  // 予報ポップアップの描画
  void drawNewsPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        nextButton.isEnabled = false;  // 最初はボタンを無効化
        // 初回のみインデックスを進める
        currentNewsIndex++;
    }
    int elapsedTime = millis() - yearPopupStartTime;

    // 全ての予報を取得
    ArrayList<ForecastInfo> allForecasts = eventManager.getAllCurrentForecasts();
    if (allForecasts == null || allForecasts.size() == 0) return;
    
    // 現在の予報を取得（インデックスを使用）
    int displayIndex = currentNewsIndex - 1;  // 表示用のインデックス
    if (displayIndex < 0 || displayIndex >= allForecasts.size()) {
      displayIndex = 0;  // 安全のためリセット
    }
    ForecastInfo forecast = allForecasts.get(displayIndex);
    
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
      text(currentNewsIndex + " / " + allForecasts.size(), (width * 0.3) + 460, 240);
    }
    
    // 予報の内容をここに記述
    fill(0);
    textSize(28);
    textAlign(LEFT, TOP);
    text(forecast.message, (width * 0.3) + 200, 290, (width * 0.7) - 370, 220);
    
    textAlign(CENTER, CENTER);
    noStroke();

    // ボタンは常に表示
    nextButton.display();
    
    // 1秒後にボタンを有効化
    if (elapsedTime >= seconds) {
      nextButton.isEnabled = true;
    }
  }

  // 予報外れポップアップの描画
  void drawMissedPopup() {
    if (!yearPopupTimerSet) {
        yearPopupStartTime = millis();
        yearPopupTimerSet = true;
        nextButton.isEnabled = false;  // 最初はボタンを無効化
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

    if (elapsedTime >= seconds) {
      nextButton.isEnabled = true;  // ボタンを有効化
      nextButton.display();
    }
  }

  // イベント履歴ポップアップの描画
  void drawEventHistoryPopup() {
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 100, (width * 0.7) - 190, height - 200);
    
    // タイトル
    fill(0);
    textSize(36);
    textAlign(CENTER, TOP);
    text("イベント履歴", width/2 + 100, 120);
    
    // イベント履歴を取得
    ArrayList<Event> history = eventManager.getEventHistory();
    
    if (history == null || history.size() == 0) {
      textSize(24);
      text("まだイベントは発生していません", width/2 + 100, height/2);
    } else {
      // イベント一覧を表示
      textAlign(LEFT, TOP);
      textSize(20);
      int yOffset = 180;
      int lineHeight = 35;
      
      for (int i = 0; i < history.size(); i++) {
        Event evt = history.get(i);
        
        // イベント名
        fill(0);
        text((i + 1) + ". " + evt.eventName, (width * 0.3) + 150, yOffset);
        
        // 効果説明（小さめのフォント）
        textSize(16);
        fill(80);
        text("   " + evt.effectMessage, (width * 0.3) + 150, yOffset + 20);
        
        yOffset += lineHeight + 15;
        textSize(20);
        
        // 画面から出そうな場合は省略
        if (yOffset > height - 150) {
          fill(100);
          textAlign(CENTER, TOP);
          text("...", width/2 + 100, yOffset);
          break;
        }
      }
    }
    
    // 閉じるボタン（ポップアップ内の右側に表示）
    textAlign(CENTER, CENTER);
    // 一時的にボタンを作成して表示
    fill(100, 150, 230);
    stroke(0);
    strokeWeight(2);
    float buttonX = width - 280;  // ポップアップの右端から内側に配置
    float buttonY = height - 150;
    ellipse(buttonX, buttonY, 150, 60);
    fill(0);
    textSize(28);
    text("戻る", buttonX, buttonY);
    noStroke();
  }

  // 予報履歴ポップアップの描画
  void drawForecastHistoryPopup() {
    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 110, 100, (width * 0.7) - 190, height - 200);
    
    // タイトル
    fill(0);
    textSize(36);
    textAlign(CENTER, TOP);
    text("予報履歴", width/2 + 100, 120);
    
    // 予報履歴を取得
    ArrayList<ForecastInfo> history = eventManager.getForecastHistory();
    
    if (history == null || history.size() == 0) {
      textSize(24);
      text("まだ予報は発表されていません", width/2 + 100, height/2);
    } else {
      // 予報一覧を表示
      textAlign(LEFT, TOP);
      textSize(18);
      int yOffset = 180;
      int lineHeight = 30;
      
      for (int i = 0; i < history.size(); i++) {
        ForecastInfo forecast = history.get(i);
        
        // 予報メッセージ
        fill(0);
        text((i + 1) + ". 【予報】", (width * 0.3) + 150, yOffset);
        
        // 予報内容
        textSize(16);
        fill(50);
        text("   " + forecast.message, (width * 0.3) + 150, yOffset + 20);
        
        // 結果（イベントが既に発生または外れが確定した場合のみ表示）
        // 予報から実際のイベント発生までのタイムラグを考慮
        boolean resultKnown = false;
        
        // イベント履歴を確認して、このイベントが既に発生したか確認
        ArrayList<Event> eventHistory = eventManager.getEventHistory();
        for (Event evt : eventHistory) {
          if (evt.eventName.equals(forecast.eventName)) {
            // イベントが発生した
            fill(50, 100, 50);
            text("   【結果】発生しました", (width * 0.3) + 150, yOffset + 40);
            yOffset += 20;
            resultKnown = true;
            break;
          }
        }
        
        // イベントが発生していない場合、外れメッセージがあるかチェック
        if (!resultKnown) {
          // 現在のターンと予報のタイミングを比較して、十分な時間が経過したか確認
          // （予報から2ターン以上経過した場合のみ外れと判定）
          if (!forecast.willOccur && currentTurn > i + 3) {  // 予報履歴のインデックス + 猶予期間
            Event relatedEvent = findEventByName(forecast.eventName);
            if (relatedEvent != null && relatedEvent.missedMessage != null && !relatedEvent.missedMessage.isEmpty()) {
              fill(100, 50, 50);
              text("   【結果】" + relatedEvent.missedMessage, (width * 0.3) + 150, yOffset + 40);
              yOffset += 20;
            }
          } else {
            // まだ結果が分からない場合は何も表示しない
            fill(100);
            text("   【結果】---", (width * 0.3) + 150, yOffset + 40);
            yOffset += 20;
          }
        }
        
        yOffset += lineHeight + 25;
        textSize(18);
        
        // 画面から出そうな場合は省略
        if (yOffset > height - 150) {
          fill(100);
          textAlign(CENTER, TOP);
          text("...", width/2 + 100, yOffset);
          break;
        }
      }
    }
    
    // 閉じるボタン（ポップアップ内の右側に表示）
    textAlign(CENTER, CENTER);
    fill(100, 150, 230);
    stroke(0);
    strokeWeight(2);
    float buttonX = width - 280;  // ポップアップの右端から内側に配置
    float buttonY = height - 150;
    ellipse(buttonX, buttonY, 150, 60);
    fill(0);
    textSize(28);
    text("戻る", buttonX, buttonY);
    noStroke();
  }
  
  // イベント名からイベントを検索するヘルパーメソッド
  Event findEventByName(String eventName) {
    if (eventManager == null || eventManager.eventTemplates == null) {
      return null;
    }
    for (Event evt : eventManager.eventTemplates) {
      if (evt != null && evt.eventName.equals(eventName)) {
        return evt;
      }
    }
    return null;
  }

  // ポップアップを閉じるためのボタン描画
  void drawCloseButton() {
  }
}
