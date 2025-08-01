// 大米をはたけ（たいまいをはたけ）- メインファイル

// ゲーム管理変数
GameState gameState;
Market market;
Broker player;
Broker ai;
int currentTurn = 1;
int maxTurns = 10;

// UI関連
PFont gameFont;
boolean showingPopup = false;
String popupType = "";
RiceCard selectedCard = null;
int selectedAmount = 1;
int selectedBrand = 0; // 買付時の選択ブランド

// 演出関連
boolean showingRevenue = false;
int revenueAnimTimer = 0;
float playerRevenue = 0;
float aiRevenue = 0;

void setup() {
  size(1280, 720);
  
  // フォント設定
  gameFont = createFont("Arial", 16, true);
  textFont(gameFont);
  
  // ゲーム初期化
  initGame();
}

void initGame() {
  gameState = new GameState();
  market = new Market();
  player = new Broker("プレイヤー", 300000); // 30万円スタート
  ai = new Broker("AI", 300000);
  currentTurn = 1;
  
  // 初期手札を配る（デモ用）
  for (int i = 0; i < 5; i++) {
    player.addCard(new RiceCard(floor(random(4))));
    ai.addCard(new RiceCard(floor(random(4))));
  }
  
  // AIの初回出荷準備
  startNewTurn();
}

void draw() {
  background(240);
  
  switch(gameState.currentState) {
    case START:
      drawStartScreen();
      break;
    case PLAYING:
      drawGameScreen();
      break;
    case GAME_OVER:
      drawGameOverScreen();
      break;
  }
  
  // 収益演出表示
  if (showingRevenue) {
    drawRevenueAnimation();
  }
  
  // ポップアップ表示
  if (showingPopup) {
    drawPopup();
  }
}

void drawStartScreen() {
  fill(0);
  textAlign(CENTER);
  textSize(48);
  text("大米をはたけ", width/2, height/2 - 100);
  
  textSize(24);
  text("米の流通市場シミュレーションゲーム", width/2, height/2 - 50);
  
  textSize(20);
  text("クリックでゲーム開始", width/2, height/2 + 50);
  
  textSize(16);
  text("チーム: ゆず, みなと, カメ, はまち", width/2, height - 50);
  
  // ゲーム説明
  textSize(14);
  textAlign(LEFT);
  text("【遊び方】", 50, height/2 + 120);
  text("1. 買付で米を購入", 50, height/2 + 145);
  text("2. 手札のカードをクリックして出荷準備", 50, height/2 + 165);
  text("3. ターン終了で市場に出荷＆売上獲得", 50, height/2 + 185);
  text("※市場の供給過多に注意！価格が下がります", 50, height/2 + 210);
}

void drawGameScreen() {
  // 左側エリア（30%）
  drawLeftPanel();
  
  // 右側エリア（70%）
  drawRightPanel();
}

void drawLeftPanel() {
  // 背景
  fill(255);
  rect(0, 0, width * 0.3, height);
  
  // 市場情報
  fill(0);
  textAlign(LEFT);
  textSize(20);
  text("市場情報", 20, 40);
  
  // 供給上限と現在の合計
  textSize(16);
  int totalInMarket = 0;
  int totalShipping = 0;
  for (int i = 0; i < 4; i++) {
    totalInMarket += market.marketStock[i];
    totalShipping += player.getShippingCount(i) + ai.getShippingCount(i);
  }
  text("供給上限: " + market.supplyLimit + "枚", 20, 70);
  text("現在合計: " + totalInMarket + "枚", 20, 90);
  if (totalShipping > 0) {
    fill(totalInMarket + totalShipping > market.supplyLimit ? color(255, 0, 0) : color(0));
    text("出荷後: " + (totalInMarket + totalShipping) + "枚", 150, 90);
    fill(0);
  }
  
  // 各ブランドの状況
  int y = 110;
  for (int i = 0; i < 4; i++) {
    // 現在の市場在庫と今回の出荷予定を合計
    int currentInMarket = market.marketStock[i];
    int playerShipping = player.getShippingCount(i);
    int aiShipping = ai.getShippingCount(i);
    int totalExpected = currentInMarket + playerShipping + aiShipping;
    
    text(RICE_BRANDS[i] + ":", 30, y);
    text("現在: " + currentInMarket + "枚", 50, y + 20);
    if (playerShipping + aiShipping > 0) {
      fill(100);
      text("(+" + (playerShipping + aiShipping) + "枚予定)", 130, y + 20);
      fill(0);
    }
    text("価格: " + int(market.getCurrentPrice(i)) + "円", 30, y + 40);
    y += 60;
  }
  
  // 環境効果
  fill(0);
  textSize(20);
  text("環境効果", 20, 350);
  textSize(16);
  text(market.currentEnvironment, 20, 380);
  
  // 環境効果の説明
  textSize(12);
  fill(100);
  String effectDesc = "";
  if (market.currentEnvironment.equals("豊作")) {
    effectDesc = "価格が10%下落";
  } else if (market.currentEnvironment.equals("不作")) {
    effectDesc = "価格が10%上昇";
  } else if (market.currentEnvironment.equals("台風")) {
    effectDesc = "特定ブランドの在庫減少";
  } else if (market.currentEnvironment.equals("豊穣祭")) {
    effectDesc = "消費量が増加";
  }
  if (!effectDesc.equals("")) {
    text(effectDesc, 20, 400);
  }
  fill(0);
  
  // プレイヤー情報
  fill(0);
  textSize(20);
  text("所持金", 20, 450);
  textSize(24);
  text(player.money / 10000 + "万円", 20, 480);
}

void drawRightPanel() {
  float rightX = width * 0.3;
  float rightWidth = width * 0.7;
  
  // 背景
  fill(250);
  rect(rightX, 0, rightWidth, height);
  
  // ターン数
  fill(0);
  textAlign(CENTER);
  textSize(24);
  text(currentTurn + "年目", rightX + rightWidth/2, 40);
  
  // 出荷準備エリア
  drawShippingArea(rightX, rightWidth);
  
  // 手札エリア
  drawHandArea(rightX, rightWidth);
  
  // アクションボタン
  drawActionButtons(rightX, rightWidth);
}

void drawShippingArea(float x, float w) {
  // 枠線
  stroke(100);
  strokeWeight(2);
  fill(255);
  rect(x + 50, 80, w - 100, 300);
  
  // 相手の出荷準備（上段）
  fill(0);
  textAlign(LEFT);
  textSize(16);
  text("相手の出荷準備", x + 60, 100);
  
  // 相手の枚数表示
  textAlign(RIGHT);
  text("合計: " + ai.shippingArea.size() + "枚", x + w - 60, 100);
  
  // 相手のカード（裏向き）をブランドごとにグループ化
  int[] aiCardCounts = new int[4];
  for (RiceCard card : ai.shippingArea) {
    aiCardCounts[card.brandType]++;
  }
  
  int xPos = 100;
  for (int i = 0; i < 4; i++) {
    if (aiCardCounts[i] > 0) {
      // 裏向きカードの表示
      fill(100);
      rect(x + xPos, 120, 80, 100);
      
      // 枚数表示
      fill(255);
      textAlign(CENTER);
      textSize(20);
      text("×" + aiCardCounts[i], x + xPos + 40, 170);
      
      xPos += 100;
    }
  }
  
  // 区切り線
  stroke(150);
  line(x + 50, 240, x + w - 50, 240);
  
  // 自分の出荷準備（下段）
  fill(0);
  textAlign(LEFT);
  text("自分の出荷準備", x + 60, 260);
  
  // 自分の枚数表示
  textAlign(RIGHT);
  text("合計: " + player.shippingArea.size() + "枚", x + w - 60, 260);
  
  // 自分のカードをブランドごとにグループ化
  int[] playerCardCounts = new int[4];
  for (RiceCard card : player.shippingArea) {
    playerCardCounts[card.brandType]++;
  }
  
  xPos = 100;
  for (int i = 0; i < 4; i++) {
    if (playerCardCounts[i] > 0) {
      RiceCard displayCard = new RiceCard(i);
      displayCard.display(x + xPos, 280);
      
      // 枚数表示
      fill(255, 0, 0);
      textAlign(CENTER);
      textSize(20);
      text("×" + playerCardCounts[i], x + xPos + 40, 270);
      
      xPos += 100;
    }
  }
}

void drawHandArea(float x, float w) {
  // 手札表示
  fill(0);
  textAlign(LEFT);
  textSize(16);
  text("手札", x + 60, 420);
  
  // カードを種類ごとにグループ化
  int[] cardCounts = new int[4];
  for (RiceCard card : player.hand) {
    cardCounts[card.brandType]++;
  }
  
  // カード表示
  int xPos = 100;
  for (int i = 0; i < 4; i++) {
    if (cardCounts[i] > 0) {
      RiceCard displayCard = new RiceCard(i);
      displayCard.display(x + xPos, 440);
      
      // 枚数表示
      fill(255, 0, 0);
      textAlign(CENTER);
      text("×" + cardCounts[i], x + xPos + 40, 430);
      
      xPos += 120;
    }
  }
}

void drawActionButtons(float x, float w) {
  // 買付ボタン
  fill(100, 200, 100);
  rect(x + 100, 600, 200, 50);
  fill(255);
  textAlign(CENTER);
  textSize(20);
  text("買付", x + 200, 635);
  
  // ターン終了ボタン（出荷して次へ）
  fill(200, 100, 100);
  rect(x + 400, 600, 200, 50);
  fill(255);
  text("出荷してターン終了", x + 500, 635);
  
  // 注意書き
  fill(0);
  textSize(14);
  text("※ターン終了時に出荷準備エリアのカードが市場に出荷されます", x + w/2, 680);
}

void drawGameOverScreen() {
  fill(0);
  textAlign(CENTER);
  textSize(48);
  text("ゲーム終了", width/2, height/2 - 100);
  
  textSize(32);
  String winner = player.money > ai.money ? "プレイヤーの勝利！" : "AIの勝利！";
  text(winner, width/2, height/2);
  
  textSize(24);
  text("プレイヤー: " + player.money / 10000 + "万円", width/2, height/2 + 50);
  text("AI: " + ai.money / 10000 + "万円", width/2, height/2 + 80);
  
  textSize(20);
  text("クリックでタイトルに戻る", width/2, height/2 + 150);
}

void drawPopup() {
  // 背景を暗くする
  fill(0, 150);
  rect(0, 0, width, height);
  
  // ポップアップウィンドウ
  fill(255);
  rect(width/2 - 200, height/2 - 150, 400, 300);
  
  fill(0);
  textAlign(CENTER);
  textSize(20);
  
  if (popupType.equals("buy")) {
    text("買付", width/2, height/2 - 100);
    
    // 各ブランドの買付ボタン
    int y = height/2 - 50;
    for (int i = 0; i < 4; i++) {
      // ブランド名と価格
      textAlign(LEFT);
      textSize(16);
      text(RICE_BRANDS[i], width/2 - 180, y);
      text(int(market.getCurrentPrice(i)) + "円", width/2 - 50, y);
      
      // 購入ボタン
      fill(100, 200, 100);
      rect(width/2 + 50, y - 15, 80, 30);
      fill(255);
      textAlign(CENTER);
      text("選択", width/2 + 90, y);
      
      fill(0);
      y += 40;
    }
  } else if (popupType.equals("buyAmount")) {
    text("購入数選択", width/2, height/2 - 100);
    text(RICE_BRANDS[selectedBrand], width/2, height/2 - 50);
    
    // 価格と合計金額表示
    float unitPrice = market.getCurrentPrice(selectedBrand);
    textSize(16);
    text("単価: " + int(unitPrice) + "円", width/2, height/2 - 20);
    
    textSize(20);
    text("選択: " + selectedAmount + "枚", width/2, height/2 + 10);
    
    // 合計金額
    float totalPrice = unitPrice * selectedAmount;
    textSize(18);
    fill(totalPrice > player.money ? color(255, 0, 0) : color(0));
    text("合計: " + int(totalPrice) + "円", width/2, height/2 + 35);
    fill(0);
    
    // 所持金表示
    textSize(14);
    text("(所持金: " + player.money + "円)", width/2, height/2 + 55);
    
    // +/-ボタン
    fill(200);
    rect(width/2 - 100, height/2 + 70, 50, 40);
    rect(width/2 + 50, height/2 + 70, 50, 40);
    fill(0);
    textSize(20);
    text("-", width/2 - 75, height/2 + 95);
    text("+", width/2 + 75, height/2 + 95);
    
    // 購入ボタン
    fill(totalPrice <= player.money ? color(100, 200, 100) : color(150));
    rect(width/2 - 50, height/2 + 130, 100, 40);
    fill(255);
    text("購入", width/2, height/2 + 155);
  } else if (popupType.equals("ship")) {
    text("出荷数選択", width/2, height/2 - 100);
    text(RICE_BRANDS[selectedCard.brandType], width/2, height/2 - 50);
    text("選択: " + selectedAmount + "枚", width/2, height/2);
    
    // 最大枚数表示
    int maxAmount = player.getHandCount(selectedCard.brandType);
    textSize(14);
    text("(最大: " + maxAmount + "枚)", width/2, height/2 + 25);
    
    // +/-ボタン
    fill(200);
    rect(width/2 - 100, height/2 + 40, 50, 40);
    rect(width/2 + 50, height/2 + 40, 50, 40);
    fill(0);
    textSize(20);
    text("-", width/2 - 75, height/2 + 65);
    text("+", width/2 + 75, height/2 + 65);
    
    // 決定ボタン
    fill(100, 200, 100);
    rect(width/2 - 50, height/2 + 100, 100, 40);
    fill(255);
    text("決定", width/2, height/2 + 125);
  } else if (popupType.equals("return")) {
    text("手札に戻す", width/2, height/2 - 100);
    text(RICE_BRANDS[selectedCard.brandType], width/2, height/2 - 50);
    text("選択: " + selectedAmount + "枚", width/2, height/2);
    
    // 最大枚数表示
    int maxAmount = player.getShippingCount(selectedCard.brandType);
    textSize(14);
    text("(最大: " + maxAmount + "枚)", width/2, height/2 + 25);
    
    // +/-ボタン
    fill(200);
    rect(width/2 - 100, height/2 + 40, 50, 40);
    rect(width/2 + 50, height/2 + 40, 50, 40);
    fill(0);
    textSize(20);
    text("-", width/2 - 75, height/2 + 65);
    text("+", width/2 + 75, height/2 + 65);
    
    // 戻すボタン
    fill(200, 100, 100);
    rect(width/2 - 50, height/2 + 100, 100, 40);
    fill(255);
    text("戻す", width/2, height/2 + 125);
  }
  
  // 閉じるボタン
  fill(200, 100, 100);
  rect(width/2 + 150, height/2 - 140, 40, 30);
  fill(255);
  text("×", width/2 + 170, height/2 - 120);
}

void mousePressed() {
  if (gameState.currentState == State.START) {
    gameState.currentState = State.PLAYING;
  } else if (gameState.currentState == State.PLAYING) {
    handleGameClick();
  } else if (gameState.currentState == State.GAME_OVER) {
    gameState.currentState = State.START;
    initGame();
  }
}

void handleGameClick() {
  float rightX = width * 0.3;
  
  // ポップアップ処理
  if (showingPopup) {
    handlePopupClick();
    return;
  }
  
  // 買付ボタン
  if (mouseX > rightX + 100 && mouseX < rightX + 300 && 
      mouseY > 600 && mouseY < 650) {
    showingPopup = true;
    popupType = "buy";
  }
  
  // ターン終了ボタン（出荷してターン終了）
  if (mouseX > rightX + 400 && mouseX < rightX + 600 && 
      mouseY > 600 && mouseY < 650) {
    endTurn();
  }
  
  // 出荷準備エリアのクリック
  checkShippingAreaClick();
  
  // 手札クリック
  checkHandClick();
}

void handlePopupClick() {
  // 閉じるボタン
  if (mouseX > width/2 + 150 && mouseX < width/2 + 190 &&
      mouseY > height/2 - 140 && mouseY < height/2 - 110) {
    showingPopup = false;
    popupType = "";
    selectedCard = null;
    selectedAmount = 1;
    selectedBrand = 0;
    return;
  }
  
  if (popupType.equals("buy")) {
    // 買付ボタンのクリック判定
    int y = height/2 - 50;
    for (int i = 0; i < 4; i++) {
      if (mouseX > width/2 + 50 && mouseX < width/2 + 130 &&
          mouseY > y - 15 && mouseY < y + 15) {
        // 購入数選択画面へ
        selectedBrand = i;
        selectedAmount = 1;
        popupType = "buyAmount";
      }
      y += 40;
    }
  } else if (popupType.equals("buyAmount")) {
    // +/-ボタン
    if (mouseX > width/2 - 100 && mouseX < width/2 - 50 &&
        mouseY > height/2 + 70 && mouseY < height/2 + 110) {
      selectedAmount = max(1, selectedAmount - 1);
    }
    if (mouseX > width/2 + 50 && mouseX < width/2 + 100 &&
        mouseY > height/2 + 70 && mouseY < height/2 + 110) {
      // 最大購入可能数の計算
      int maxAffordable = int(player.money / market.getCurrentPrice(selectedBrand));
      selectedAmount = min(maxAffordable, selectedAmount + 1);
    }
    
    // 購入ボタン
    if (mouseX > width/2 - 50 && mouseX < width/2 + 50 &&
        mouseY > height/2 + 130 && mouseY < height/2 + 170) {
      float totalPrice = market.getCurrentPrice(selectedBrand) * selectedAmount;
      if (player.money >= totalPrice) {
        // 複数枚購入処理
        for (int i = 0; i < selectedAmount; i++) {
          player.buyCard(selectedBrand, market.getCurrentPrice(selectedBrand));
        }
        showingPopup = false;
        popupType = "";
        selectedAmount = 1;
      }
    }
  } else if (popupType.equals("ship")) {
    // +/-ボタン
    if (mouseX > width/2 - 100 && mouseX < width/2 - 50 &&
        mouseY > height/2 + 40 && mouseY < height/2 + 80) {
      selectedAmount = max(1, selectedAmount - 1);
    }
    if (mouseX > width/2 + 50 && mouseX < width/2 + 100 &&
        mouseY > height/2 + 40 && mouseY < height/2 + 80) {
      int maxAmount = player.getHandCount(selectedCard.brandType);
      selectedAmount = min(maxAmount, selectedAmount + 1);
    }
    
    // 決定ボタン
    if (mouseX > width/2 - 50 && mouseX < width/2 + 50 &&
        mouseY > height/2 + 100 && mouseY < height/2 + 140) {
      player.moveToShipping(selectedCard.brandType, selectedAmount);
      showingPopup = false;
      popupType = "";
      selectedCard = null;
      selectedAmount = 1;
    }
  } else if (popupType.equals("return")) {
    // +/-ボタン
    if (mouseX > width/2 - 100 && mouseX < width/2 - 50 &&
        mouseY > height/2 + 40 && mouseY < height/2 + 80) {
      selectedAmount = max(1, selectedAmount - 1);
    }
    if (mouseX > width/2 + 50 && mouseX < width/2 + 100 &&
        mouseY > height/2 + 40 && mouseY < height/2 + 80) {
      int maxAmount = player.getShippingCount(selectedCard.brandType);
      selectedAmount = min(maxAmount, selectedAmount + 1);
    }
    
    // 戻すボタン
    if (mouseX > width/2 - 50 && mouseX < width/2 + 50 &&
        mouseY > height/2 + 100 && mouseY < height/2 + 140) {
      player.moveFromShipping(selectedCard.brandType, selectedAmount);
      showingPopup = false;
      popupType = "";
      selectedCard = null;
      selectedAmount = 1;
    }
  }
}

void checkHandClick() {
  float rightX = width * 0.3;
  
  // カードの位置を計算
  int[] cardCounts = new int[4];
  for (RiceCard card : player.hand) {
    cardCounts[card.brandType]++;
  }
  
  int xPos = 100;
  for (int i = 0; i < 4; i++) {
    if (cardCounts[i] > 0) {
      // カードのクリック判定
      if (mouseX > rightX + xPos && mouseX < rightX + xPos + 80 &&
          mouseY > 440 && mouseY < 540) {
        // 出荷数選択ポップアップを表示
        selectedCard = new RiceCard(i);
        selectedAmount = 1;
        showingPopup = true;
        popupType = "ship";
        return;
      }
      xPos += 120;
    }
  }
}

void checkShippingAreaClick() {
  float rightX = width * 0.3;
  
  // 出荷準備エリアのカードをクリックして戻す
  int[] playerCardCounts = new int[4];
  for (RiceCard card : player.shippingArea) {
    playerCardCounts[card.brandType]++;
  }
  
  int xPos = 100;
  for (int i = 0; i < 4; i++) {
    if (playerCardCounts[i] > 0) {
      // カードのクリック判定
      if (mouseX > rightX + xPos && mouseX < rightX + xPos + 80 &&
          mouseY > 280 && mouseY < 380) {
        // 戻す枚数選択ポップアップを表示
        selectedCard = new RiceCard(i);
        selectedAmount = 1;
        showingPopup = true;
        popupType = "return";
        return;
      }
      xPos += 100;
    }
  }
}

void endTurn() {
  // 収益計算の演出開始
  startRevenueAnimation();
}

void startRevenueAnimation() {
  // 収益を事前計算
  playerRevenue = 0;
  aiRevenue = 0;
  
  for (RiceCard card : player.shippingArea) {
    playerRevenue += market.getCurrentPrice(card.brandType);
  }
  
  for (RiceCard card : ai.shippingArea) {
    aiRevenue += market.getCurrentPrice(card.brandType);
  }
  
  showingRevenue = true;
  revenueAnimTimer = 0;
}

void finishTurn() {
  // ターン終了処理
  market.processTurn(player, ai);
  currentTurn++;
  
  if (currentTurn > maxTurns) {
    gameState.currentState = State.GAME_OVER;
  } else {
    startNewTurn();
  }
}

void startNewTurn() {
  // 古米チェック
  removeExpiredCards();
  
  // AIの出荷準備をクリア
  ai.shippingArea.clear();
  
  // AIの自動行動
  ai.aiTurn(market);
  
  // AIの出荷戦略
  // 価格が高いブランドを優先的に出荷
  ArrayList<Integer> highPriceBrands = new ArrayList<Integer>();
  for (int i = 0; i < 4; i++) {
    if (market.getCurrentPrice(i) >= 12000) { // 基準価格の1.2倍以上
      highPriceBrands.add(i);
    }
  }
  
  // 出荷枚数決定（手札の30-60%）
  int aiShipCount = int(ai.hand.size() * random(0.3, 0.6));
  aiShipCount = max(1, min(aiShipCount, ai.hand.size()));
  
  // 高価格ブランドから優先的に出荷
  for (int i = 0; i < aiShipCount && ai.hand.size() > 0; i++) {
    boolean shipped = false;
    
    // 高価格ブランドがある場合はそれを優先
    if (highPriceBrands.size() > 0) {
      for (int brand : highPriceBrands) {
        if (ai.getHandCount(brand) > 0) {
          ai.moveToShipping(brand, 1);
          shipped = true;
          break;
        }
      }
    }
    
    // 高価格ブランドがなければランダムに選択
    if (!shipped) {
      int randomIndex = int(random(ai.hand.size()));
      RiceCard card = ai.hand.get(randomIndex);
      ai.moveToShipping(card.brandType, 1);
    }
  }
}

void removeExpiredCards() {
  // プレイヤーの古米削除
  for (int i = player.hand.size() - 1; i >= 0; i--) {
    if (player.hand.get(i).isExpired()) {
      player.hand.remove(i);
    }
  }
  
  // AIの古米削除
  for (int i = ai.hand.size() - 1; i >= 0; i--) {
    if (ai.hand.get(i).isExpired()) {
      ai.hand.remove(i);
    }
  }
}

void drawRevenueAnimation() {
  // 背景を暗くする
  fill(0, 100);
  rect(0, 0, width, height);
  
  // 演出ウィンドウ
  fill(255);
  stroke(0);
  strokeWeight(3);
  rect(width/2 - 300, height/2 - 200, 600, 400);
  
  // タイトル
  fill(0);
  textAlign(CENTER);
  textSize(36);
  text("売上計算", width/2, height/2 - 150);
  
  // アニメーション進行
  revenueAnimTimer++;
  
  // プレイヤーの売上表示
  if (revenueAnimTimer > 30) {
    textSize(24);
    textAlign(LEFT);
    text("プレイヤー:", width/2 - 250, height/2 - 50);
    
    // 金額をアニメーション表示
    float displayPlayerRevenue = 0;
    if (revenueAnimTimer < 90) {
      displayPlayerRevenue = lerp(0, playerRevenue, (revenueAnimTimer - 30) / 60.0);
    } else {
      displayPlayerRevenue = playerRevenue;
    }
    
    textAlign(RIGHT);
    fill(0, 150, 0);
    text("+" + int(displayPlayerRevenue) + "円", width/2 + 200, height/2 - 50);
  }
  
  // AIの売上表示
  if (revenueAnimTimer > 60) {
    fill(0);
    textSize(24);
    textAlign(LEFT);
    text("AI:", width/2 - 250, height/2);
    
    // 金額をアニメーション表示
    float displayAiRevenue = 0;
    if (revenueAnimTimer < 120) {
      displayAiRevenue = lerp(0, aiRevenue, (revenueAnimTimer - 60) / 60.0);
    } else {
      displayAiRevenue = aiRevenue;
    }
    
    textAlign(RIGHT);
    fill(0, 150, 0);
    text("+" + int(displayAiRevenue) + "円", width/2 + 200, height/2);
  }
  
  // 合計表示
  if (revenueAnimTimer > 120) {
    stroke(0);
    strokeWeight(1);
    line(width/2 - 250, height/2 + 40, width/2 + 250, height/2 + 40);
    
    fill(0);
    textSize(28);
    textAlign(LEFT);
    text("新しい所持金:", width/2 - 250, height/2 + 80);
    
    textAlign(RIGHT);
    text((player.money + int(playerRevenue)) / 10000 + "万円", width/2 + 200, height/2 + 80);
    
    textSize(20);
    fill(100);
    textAlign(CENTER);
    
    // 供給過多の警告
    int totalAfterShipping = 0;
    for (int i = 0; i < 4; i++) {
      totalAfterShipping += market.marketStock[i] + player.getShippingCount(i) + ai.getShippingCount(i);
    }
    
    if (totalAfterShipping > market.supplyLimit) {
      fill(255, 0, 0);
      text("※供給過多により価格が下落しました！", width/2, height/2 + 130);
    }
  }
  
  // クリックで次へ
  if (revenueAnimTimer > 150) {
    fill(100);
    textSize(16);
    textAlign(CENTER);
    text("クリックで次のターンへ", width/2, height/2 + 170);
    
    // クリックで演出終了
    if (mousePressed) {
      showingRevenue = false;
      revenueAnimTimer = 0;
      finishTurn();
    }
  }
}