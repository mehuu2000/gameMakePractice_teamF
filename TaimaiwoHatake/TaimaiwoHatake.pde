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
int pMoney = 40;
int eMoney = 40;

// ========== UI状態変数 ==========
boolean showingPopup = false; // ポップアップ表示フラグ
String popupType = ""; // ポップアップの種類
int selectedBrandId = -1; // 選択されたブランド(買い付けフェーズなど)
int selectedAmount = 1; // 選択されたカードの数量

// ========== 定数 ==========
final String[] RICE_BRANDS = {"りょうおもい", "ほしひかり", "ゆめごこち", "つやおうじ"};
final int WINDOW_WIDTH = 1280;
final int WINDOW_HEIGHT = 720;
final float LEFT_PANEL_WIDTH = 0.3;   // 左パネルの幅（30%）
final float RIGHT_PANEL_WIDTH = 0.7;  // 右パネルの幅（70%）

// ========== 変数（変更可能） ==========
RiceBrand[] riceBrandsInfo;

// ========== ポップアップ管理 ==========
void showPopup(String type) {
  showingPopup = true;
  popupType = type;
  selectedAmount = 1;
}

void closePopup() {
  showingPopup = false;
  popupType = "";
  selectedBrandId = -1;
  selectedAmount = 1;
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
void selectBrand(int riceBrandId) {
  selectedBrandId = riceBrandId;
  selectedAmount = 1;
}

void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
}

void setup() {
  background(255);

  // フォント設定
  gameFont = createFont("HGSGyoshotai", 16, true);
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
  riceBrandsInfo = new RiceBrand[] {
    new RiceBrand("りょうおもい", color(255, 200, 200), 10000),
    new RiceBrand("ほしひかり", color(200, 200, 255), 10000),
    new RiceBrand("ゆめごこち", color(200, 255, 200), 10000),
    new RiceBrand("つやおうじ", color(255, 255, 200), 10000)
  };

  // UI系
  ui = new UI(gameState);
  leftPanel = new LeftPanel(ui);
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
  case TITLE:
    ui.drawTitleScreen();
    break;
  case START:
    ui.drawStartScreen(market.supplyLimit);
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
  leftPanel.drawMarketInfo();
  leftPanel.drawEnvironment();

  // 右側エリア（70%）
  rightPanel.drawRightPanel();
  rightPanel.drawTurnInfo(currentTurn);
  rightPanel.drawMoneyInfo(pMoney, eMoney);
  rightPanel.drawShippingArea();
  rightPanel.drawAIShippingArea();
}

void keyPressed() {
  if (keyPressed == true) {
    background(255);
    textFlag = 1;
  }
}
