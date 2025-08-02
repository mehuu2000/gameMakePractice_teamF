int textFlag = 0;

PFont gameFont;

// ========== ゲームオブジェクト ==========
GameState gameState;
Market market;
Player player;
AI ai;
GameLogic gameLogic;

// UI系オブジェクト
UI ui;
LeftPanel leftPanel;
RightPanel rightPanel;
Popup popup;
CardVisual cardVisual;

// ========== ゲーム進行変数 ==========
int currentTurn = 1;
int maxTurns = 11; // 要相談

// ========== UI状態変数 ==========
boolean showingPopup = false; // ポップアップ表示フラグ
String popupType = ""; // ポップアップの種類
RiceCard selectedCard = null; // 選択されたカード(手札など)
int selectedAmount = 1; // 選択されたカードの数量
int selectedBrand = 0; // 選択されたブランド(買い付けフェーズなど)

// ========== 定数 ==========
final String[] RICE_BRANDS = {"りょうおもい", "ほしひかり", "ゆめごこち", "つやおうじ"};
final int WINDOW_WIDTH = 1280;
final int WINDOW_HEIGHT = 720;
final float LEFT_PANEL_WIDTH = 0.3;   // 左パネルの幅（30%）
final float RIGHT_PANEL_WIDTH = 0.7;  // 右パネルの幅（70%）

// ========== ポップアップ管理 ==========
void showPopup(String type) {
  showingPopup = true;
  popupType = type;
  selectedAmount = 1;
}

void closePopup() {
  showingPopup = false;
  popupType = "";
  selectedCard = null;
  selectedAmount = 1;
  selectedBrand = 0;
}

// ========== ターン管理 ==========
void nextTurn() {
  currentTurn++;
  if (currentTurn > maxTurns) {
    // ゲーム終了処理、結果画面の表示など
    // もしくは次ターン米騒動?
  }
}

void restartGame() {
  currentTurn = 1;
  initGame();
}

// ========== カード選択 ==========
void selectCard(RiceCard card) {
    selectedCard = card;
    selectedAmount = 1;
}

void selectBrand(int brand) {
    selectedBrand = brand;
}

public void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
}

void setup() {
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
  gameLogic = new GameLogic();
  player = new Player();
  ai = new AI();

  // UI系
  ui = new UI();
  leftPanel = new LeftPanel();
  rightPanel = new RightPanel();
  popup = new Popup();   
  cardVisual = new CardVisual();   

  currentTurn = 1;
  
  // AIの初回出荷準備関数
  // これは予定
  // gameLogic.dealInitialCards();

}

// メイン描画ループ
// ここでゲームの状態に応じた描画を行う
void draw() {
  background(240);
  
  switch(gameState.currentState) {
    case TEST:
      ui.draw_UHO(textFlag);
      break;
    case PLAYING:
      drawGameScreen();
      break;
  }
  
  // ポップアップ制御
  if (showingPopup) {
    popup.drawPopup(popupType);
  }
}

// ゲーム画面の描画
// 左側に市場、右側にゲーム状態を表示
void drawGameScreen() {
  // 左側エリア（30%）
  leftPanel.drawLeftPanel();
  
  // 右側エリア（70%）
  rightPanel.drawRightPanel();
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
