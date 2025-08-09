// 右側のパネルを描画するクラス
class RightPanel {
  // ホバー状態の管理
  boolean isHoveringEventBox = false;
  boolean isHoveringNewsBox = false;
  
  // 右側のパネル全体管理
  void drawRightPanel() {
    float rightX = width * 0.3;
    float rightWidth = width * 0.7;

    // 背景
    fill(250);
    //rect(rightX, 0, rightWidth, height);

    textAlign(CENTER);

    stroke(0);
    strokeWeight(5);
    line(width * 0.3 + 5, 0, width * 0.3 + 5, height);

    cardVisual.loadCardImages();

    drawTurnInfo();
    drawPointInfo();
    drawButtons();
    drawPhoto();
    drawShippingArea();
    drawAIShippingArea();
    drawHandCards();
    drawPlayerFieldCards();
    drawEnemyFieldCards();
    drawEventName();
    drawNewsName();
    drawButtons();
    
    // ホバー時のイベント効果表示
    checkEventHover();
    if (isHoveringEventBox) {
      drawEventEffectTooltip();
    }
    
    // ホバー時の予報表示
    checkNewsHover();
    if (isHoveringNewsBox) {
      drawNewsTooltip();
    }
  }

  /* 以下は実装例 */

  // ターン数表示
  void drawTurnInfo() {
    stroke(21, 96, 130);
    strokeWeight(3);
    fill(250);
    rect(1200, -3, 150, 120, 0, 0, 0, 40);
    rect(1133, -3, 150, 60, 0, 0, 0, 40);

    fill(21, 96, 130);
    textSize(40);
    text(currentYear_season[0] + "年目", 1213, 42);
    text(SEASONS[currentYear_season[1]], 1240, 100);

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
    //rect(width * 0.3 + 180, 280, 560, 140);
  }
  // AI出荷準備エリア
  void drawAIShippingArea() {
    fill(255, 0, 0);
    //rect(width * 0.3 + 180, 130, 560, 140);
    strokeWeight(1);
  }

  // プレイヤーの場札の描画
  void drawPlayerFieldCards() {
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(250);
      stroke(0);
      stroke(riceBrandsInfo[i].brandColor);

      // 個数分重ねて描画(少しずらす)
      if (player.getSumLoadRice(i) > 0) {
        image(cardVisual.cardImages[i], (width * 0.3) + 260 + (115 * i), height/2 - 65, 70, 105);

        // 個数を表示するための下地
        noStroke();
        fill(21, 96, 130);
        ellipse((width * 0.3) + 215 + (115 * i) + 107, height/2 - 63, 30, 30);
        textAlign(CENTER, CENTER);
        fill(250);
        textSize(20);
        text(player.getSumLoadRice(i), (width * 0.3) + 219 + (115 * i) + 105, height/2 - 64);
      }
    }

    noStroke();
    fill(0);
  }
  
  // 敵の場札の描画
  void drawEnemyFieldCards() {
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(250);
      stroke(0);
      stroke(riceBrandsInfo[i].brandColor);
      
      tint(150); // 画像を150/255の割合で暗くする。
      image(cardVisual.cardImages[i], (width * 0.3) + 260 + (115 * i), height/2 - 215, 70, 105);
      tint(255);

      // 個数を表示するための下地
      noStroke();
      fill(21, 96, 130);
      ellipse((width * 0.3) + 215 + (115 * i) + 107, height/2 - 213, 30, 30);
      textAlign(CENTER, CENTER);
      fill(250);
      textSize(20);
      text("？", (width * 0.3) + 218 + (115 * i) + 105, height/2 - 214);
    }

    noStroke();
    fill(0);
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
          image(cardVisual.cardImages[i], (width * 0.3) + 160 + (140 * i) + (j * 3), height/2 + 160 - (j * 2), 120, 180);
        }
      } else {
        image(cardVisual.cardImages[i], (width * 0.3) + 160 + (140 * i), height/2 + 160, 120, 180);
      }

      // 個数を表示するための下地
      noStroke();
      fill(21, 96, 130);

      if (!showingPopup ||popupType.equals("year")) { // ポップアップの表示をしていない場合、年度のポップアップを表示している場合
        // 右上
        ellipse((width * 0.3) + 160 + (140 * i) + 120, height/2 + 160, 30, 30);
        textAlign(CENTER, CENTER);
        fill(250);
        textSize(20);
        text(brandCount, (width * 0.3) + 160 + (140 * i) + 120, height/2 + 159);
      } else { // ポップアップの表示をしている場合
        ellipse((width * 0.3) + 160 + (140 * i) + 120, height/2 + 330, 30, 30);
        textAlign(CENTER, CENTER);
        fill(250);
        textSize(20);
        text(brandCount, (width * 0.3) + 160 + (140 * i) + 120, height/2 + 329);
      }
    }

    noStroke();
    fill(0);
  }
  
  // 写真の描画
  void drawPhoto() {
    // トラックの描画
    image(images[0], width - 180, height/2 + 110, 219, 137);

    //矢印の描画
    image(images[1], (width * 0.3) - 5, height/2 - 230, 200, 300);

    //倉庫の描画
    image(images[2], width/2 - 130, height/2 + 50, 600, 388);

    //敵の描画
    image(images[3], width/2 + 100, 0, 220, 160);

    //敵のトラックの描画
    image(images[5], 520, 80, 599, 234);

    //味方のトラックの描画
    image(images[4], 520, 230, 599, 234);
  }

  boolean onLoadBrandClicked() {
    // 当たり判定をチェック
    if (player.getSumLoadRice(0) > 0) {
      if (mouseX > (width * 0.3) + 260 && mouseX < (width * 0.3) + 330 &&
        mouseY > height/2 - 65 && mouseY < height/2 + 45) {
        println("a");
        gameState.selectBrandBack(0);
        return true;
      }
    }

    if (player.getSumLoadRice(1) > 0) {
      if (mouseX > (width * 0.3) + 375 && mouseX < (width * 0.3) + 445 &&
        mouseY > height/2 - 65 && mouseY < height/2 + 45) {
        println("a");
        gameState.selectBrandBack(1);
        return true;
      }
    }

    if (player.getSumLoadRice(2) > 0) {
      if (mouseX > (width * 0.3) + 490 && mouseX < (width * 0.3) + 560 &&
        mouseY > height/2 - 65 && mouseY < height/2 + 45) {
        println("a");
        gameState.selectBrandBack(2);
        return true;
      }
    }

    if (player.getSumLoadRice(3) > 0) {
      if (mouseX > (width * 0.3) + 605 && mouseX < (width * 0.3) + 675 &&
        mouseY > height/2 - 65 && mouseY < height/2 + 45) {
        println("a");
        gameState.selectBrandBack(3);
        return true;
      }
    }

    return false;
  }

  // 効果名ボックスのクリック判定
  boolean onEventBoxClicked() {
    // rect(width - 155, height/3 - 50, 160, 60, 10) の範囲をチェック
    if (mouseX >= width - 155 && mouseX <= width - 155 + 160 &&
        mouseY >= height/3 - 50 && mouseY <= height/3 - 50 + 60) {
      // イベント履歴ポップアップを表示
      showPopup("eventHistory");
      return true;
    }
    return false;
  }

  boolean onBrand1Clicked() {
    // 当たり判定をチェック
    if (mouseX > (width * 0.3) + 160 && mouseX < (width * 0.3) + 280 &&
      mouseY > height/2 + 160 && mouseY < height/2 + 320) {
      gameState.selectBrandSubmit(0);
      ses[3].play();
      ses[3].rewind();
      return true;
    } else if (mouseX > (width * 0.3) + 300 && mouseX < (width * 0.3) + 420 &&
      mouseY > height/2 + 160 && mouseY < height/2 + 320) {
      gameState.selectBrandSubmit(1);
      ses[3].play();
      ses[3].rewind();
      return true;
    } else if (mouseX > (width * 0.3) + 440 && mouseX < (width * 0.3) + 560 &&
      mouseY > height/2 + 160 && mouseY < height/2 + 320) {
      gameState.selectBrandSubmit(2);
      ses[3].play();
      ses[3].rewind();
      return true;
    } else if (mouseX > (width * 0.3) + 580 && mouseX < (width * 0.3) + 700 &&
      mouseY > height/2 + 160 && mouseY < height/2 + 320) {
      gameState.selectBrandSubmit(3);
      ses[3].play();
      ses[3].rewind();
      return true;
    }

    return false;
  }
    
  // 効果名の描画
  void drawEventName(){
    fill(240);
    stroke(5);
    rect(width - 155, height/3 - 50, 160, 60, 10);
    
    // 現在のイベント名を表示
    Event currentEvent = null;
    if (eventManager != null) {
      currentEvent = eventManager.getCurrentEvent();
    }
    
    fill(0);
    if (currentEvent != null && !currentEvent.eventName.equals("通常")) {
      // イベント名のサイズを調整して表示
      textSize(20);
      text(currentEvent.eventName, width - 70, height/3 - 20);
    } else {
      textSize(20);
      text("なし", width - 75, height/3 - 20);
    }
    
    noStroke();
  }
  
    // 予報の描画
  void drawNewsName(){
    fill(240);
    stroke(5);
    rect(width - 155, height/3 + 50, 160, 60, 10);
    
    fill(0);
    textSize(20);
    text("予報", width - 75, height/3 + 80);
    
    noStroke();
  }
    

  void drawButtons() {
    playDescribeButton.display();
    buyPopupButton.display();
    submitButton.display();
  }
  
  // イベントボックスのホバー状態をチェック
  void checkEventHover() {
    // rect(width - 155, height/3 - 50, 160, 60, 10) の範囲をチェック
    if (mouseX >= width - 155 && mouseX <= width - 155 + 160 &&
        mouseY >= height/3 - 50 && mouseY <= height/3 - 50 + 60) {
      isHoveringEventBox = true;
    } else {
      isHoveringEventBox = false;
    }
  }
  
  // イベント効果のツールチップを表示
  void drawEventEffectTooltip() {
    Event currentEvent = null;
    if (eventManager != null) {
      currentEvent = eventManager.getCurrentEvent();
    }
    
    // イベントが存在し、通常イベントでない場合のみ表示
    if (currentEvent != null && !currentEvent.eventName.equals("通常")) {
      // ツールチップの位置（イベントボックスの少し下）
      float tooltipX = width - 280;
      float tooltipY = height/3 + 20;
      float tooltipWidth = 280;
      float tooltipHeight = 100;
      
      // ツールチップの背景
      fill(255, 255, 240);
      stroke(100);
      strokeWeight(2);
      rect(tooltipX, tooltipY, tooltipWidth, tooltipHeight, 10);
      
      // イベント名
      fill(0);
      textAlign(CENTER, TOP);
      textSize(20);
      text("【" + currentEvent.eventName + "】", tooltipX + tooltipWidth/2, tooltipY + 10);
      
      // イベントの説明
      textSize(14);
      textAlign(LEFT, TOP);
      text(currentEvent.effectMessage, tooltipX + 10, tooltipY + 40, tooltipWidth - 20, tooltipHeight - 50);
      
      // 持続時間（残りターン数）
      if (currentEvent.duration > 1) {
        textSize(12);
        fill(100);
        textAlign(RIGHT, BOTTOM);
        text("残り" + currentEvent.duration + "ターン", tooltipX + tooltipWidth - 10, tooltipY + tooltipHeight - 5);
      }
      
      // テキスト配置をリセット
      textAlign(CENTER, CENTER);
      noStroke();
    }
  }
  
  // 予報ボックスのホバー状態をチェック
  void checkNewsHover() {
    // rect(width - 155, height/3 + 50, 160, 60, 10) の範囲をチェック
    if (mouseX >= width - 155 && mouseX <= width - 155 + 160 &&
        mouseY >= height/3 + 50 && mouseY <= height/3 + 50 + 60) {
      isHoveringNewsBox = true;
    } else {
      isHoveringNewsBox = false;
    }
  }
  
  // 予報のツールチップを表示
  void drawNewsTooltip() {
    ArrayList<ForecastInfo> currentForecasts = null;
    if (eventManager != null) {
      currentForecasts = eventManager.getAllCurrentForecasts();
    }
    
    // 予報が存在する場合のみ表示
    if (currentForecasts != null && currentForecasts.size() > 0) {
      // ツールチップの位置（予報ボックスの少し下）
      float tooltipX = width - 350;
      float tooltipY = height/3 + 120;
      float tooltipWidth = 350;
      float tooltipHeight = 150;
      
      // ツールチップの背景
      fill(255, 255, 240);
      stroke(100);
      strokeWeight(2);
      rect(tooltipX, tooltipY, tooltipWidth, tooltipHeight, 10);
      
      // タイトル
      fill(0);
      textAlign(CENTER, TOP);
      textSize(20);
      text("【今回の予報】", tooltipX + tooltipWidth/2, tooltipY + 10);
      
      // 予報内容
      textSize(16);
      textAlign(LEFT, TOP);
      int yOffset = 40;
      for (int i = 0; i < currentForecasts.size(); i++) {
        ForecastInfo forecast = currentForecasts.get(i);
        text((i+1) + ". " + forecast.message, tooltipX + 10, tooltipY + yOffset, tooltipWidth - 20, 40);
        yOffset += 45;
        
        // 表示しきれない場合は省略
        if (yOffset > tooltipHeight - 20) {
          text("...", tooltipX + tooltipWidth/2, tooltipY + yOffset);
          break;
        }
      }
      
      // テキスト配置をリセット
      textAlign(CENTER, CENTER);
      noStroke();
    }
  }
  
  // 予報ボックスのクリック判定
  boolean onNewsBoxClicked() {
    // rect(width - 155, height/3 + 50, 160, 60, 10) の範囲をチェック
    if (mouseX >= width - 155 && mouseX <= width - 155 + 160 &&
        mouseY >= height/3 + 50 && mouseY <= height/3 + 50 + 60) {
      // 予報履歴ポップアップを表示
      showPopup("forecastHistory");
      return true;
    }
    return false;
  }
}
