int textFlag = 0;

// ゲーム管理変数
GameState gameState;
Market market;
Broker broker;
// Broker player;
// Broker ai;
int currentTurn = 1;
int maxTurns = 11; // 要相談

// UI関連
PFont gameFont;
// boolean showingPopup = false;
// Card selectedCard = null;
// int selectedAmount = 1;
// int selectedBrand = 0;

void setup() {
  size(1280, 720);
  background(255);

  // フォント設定
  gameFont = createFont("Meiryo", 16, true);
  textFont(gameFont);
  textAlign(CENTER, CENTER);

  initGame();
}

// ゲーム初期化
// ここでゲームの初期状態を設定
void initGame() {
  gameState = new GameState();
  market = new Market();
  broker = new Broker();
  // player = new Broker("プレイヤー", 300000);
  // ai = new Broker("AI", 300000);
  currentTurn = 1;
  
  // AIの初回出荷準備関数

}

// メイン描画ループ
// ここでゲームの状態に応じた描画を行う
void draw() {
  background(240);
  
  switch(gameState.currentState) {
    case TEST:
      draw_UHO() ;
      break;
    // case START:
    //   drawStartScreen();
    //   break;
    case PLAYING:
      drawGameScreen();
      break;
    // case FINISHED:
    //   drawGameOver();
    //   break;
  }
  
  // ポップアップ制御
  // if (showingPopup) {
  //   drawPopup();
  // }
}

// ゲーム画面の描画
// 左側に市場、右側にゲーム状態を表示
void drawGameScreen() {
  // 左側エリア（30%）
  market.drawLeftPanel();
  
  // 右側エリア（70%）
  broker.drawRightPanel();
}

void draw_UHO() {
  fill(0);
  if (textFlag == 0) {
    textSize(100);
    text("ボタンを押せ！！！！！", width/2, height/2);
  } else if (textFlag == 1) {
    textSize(300);
    text("うほ", width/2, height/2);
  }
}

void keyPressed() {
  if(keyPressed == true){
    background(255);
    textFlag = 1;
  }
}
void mousePressed() {
  if (gameState.currentState == State.TEST) {
    gameState.currentState = State.PLAYING;
  }
}
