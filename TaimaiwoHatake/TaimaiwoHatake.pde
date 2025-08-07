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

// ボタン系オブジェクト
NormalButton startButton; // スタートボタン
NormalButton describeButton; // 説明ボタン
NormalButton endButton; // 終了ボタン

TriangleButton plus1SelectedButton; // 現在の選択ブランドの選択数を1増やす
TriangleButton minus1SelectedButton; // 現在の選択ブランドの選択数を1減らす

TriangleButton[] brandPlus1Buttons; // 購入の際に特定のブランドの選択数を1増やすボタン
TriangleButton[] brandMinus1Buttons; // 購入の際に特定のブランドの選択数を1減らすボタン

EllipseButton closePopupButton; // ポップアップを閉じるボタン（通常）
EllipseButton closeEndPopupButton; // ポップアップを閉じるボタン（却下ボタン）
EllipseButton loadButton; // ポップアップの提出ボタン
EllipseButton returnButton; // ポップアップの返却ボタン
EllipseButton turnEndButton; // ターン終了を確定するボタン

EllipseButton buyButton; // 購入ボタン

EllipseButton playDescribeButton; // 説明画面に移動するボタン
EllipseButton submitButton; // 出荷ボタン


// ========== ゲーム進行変数 ==========
int currentTurn = 1;
int[] currentYear_season = {1, 1}; // 年と季節を管理する配列。年, 季節(1:秋, 2:冬, 3:春, 4:夏, )
int maxTurns = 11; // 要相談

// ========== UI状態変数 ==========
boolean showingPopup = false; // ポップアップ表示フラグ
String popupType = ""; // ポップアップの種類
int selectedBrandId = 0; // 選択されたブランド(買い付けフェーズなど)
int totalPrice = 0; // 購入合計金額

// 集計結果で使用する変数
int playerProfit = 0; // プレイヤーの利益
int aiProfit = 0; // AIの利益
int[] playerLoadedRices; // プレイヤーが前シーズンで出荷した米の数
int[] aiLoadedRices; // AIが前シーズンで出荷した米の数
int[] marketStockKeep; // その時の在庫を保持するための配列


// ========== 定数 ==========
final String[] RICE_BRANDS = {"りょうおもい", "ほしひかり", "ゆめごこち", "つやおうじ"};
final String[] SEASONS = {"秋", "冬", "春", "夏",}; // 季節の名前
final int YEAR = 0; // 年のインデックス
final int SEASON = 1; // 季節のインデックス
final int WINDOW_WIDTH = 1280; // ウィンドウ幅
final int WINDOW_HEIGHT = 720; // ウィンドウ高さ
final int PLAYER_POINT = 5000; // プレイヤー初期所持金
final int ENEMY_POINT = 5000; // AI初期所持金
final float LEFT_PANEL_WIDTH = 0.3;   // 左パネルの幅（30%）
final float RIGHT_PANEL_WIDTH = 0.7;  // 右パネルの幅（70%）
final int[] BASE_CARD_POINTS = {100, 110, 120, 130}; // 基本のカードポイントの係数
final int LOWER_LIMIT_RICE_POINT= 10; // 米の下限価格

// ========== 変数（変更可能） ==========
RiceBrand[] riceBrandsInfo;
int[] selectedAmounts; // 選択されたカードの数量。インデックス = ブランドID
int[] riceBrandRanking; // ブランドの供給数ランキング（重複なし）

int sumBrandCount = 0; // 総数を管理する変数
boolean isFirst = false; // 初回フラグ

boolean isSupplyOver = false; // 供給数が上限を超えたかどうかのフラグ

int baseEventEffect = 1; // イベント効果の基本値
int eventEffect = 1; // イベント効果の倍率

// ========== 変数管理 ==========
// イベントの倍率を更新
void updateEventEffect(int effect) {
  eventEffect = eventEffect * effect;
}

// イベントの倍率をリセット
void resetEventEffect() {
  eventEffect = baseEventEffect; // デフォルトの効果倍率にリセット
}

// 現在の年と季節を返す関数
int[] getCurrentYear() {
  int[] year_season = new int[currentYear_season.length];
  year_season[0] = int((currentTurn-1)/4) + 1; // 年
  year_season[1] = currentTurn % 4; // 季節(0:秋, 1:冬, 2:春, 3:夏)
  return year_season;
}

// ========== ポップアップ管理 ==========
void showPopup(String type) {
  showingPopup = true;
  popupType = type;
  resetSelectedAmounts();
}

void closePopup() {
  showingPopup = false;
  popupType = "";
  selectedBrandId = -1;
  resetSelectedAmounts();

  sumBrandCount = 0;
  isFirst = false;

  totalPrice = 0;
}

// selectedAmountsの初期化
void resetSelectedAmounts() {
  for (int i = 0; i < selectedAmounts.length; i++) {
    selectedAmounts[i] = 0;
  }
}

// ゲームを再スタートする関数(現在非対応)
void restartGame() {
  currentTurn = 1;
  initGame();
}

// ========== カード選択 ==========
void selectBrand(int riceBrandId) {
  selectedBrandId = riceBrandId;
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
  riceBrandsInfo = new RiceBrand[] {
    new RiceBrand("りょうおもい", color(220, 80, 80), BASE_CARD_POINTS[0]),
    new RiceBrand("ほしひかり", color(80, 80, 220), BASE_CARD_POINTS[1]),
    new RiceBrand("ゆめごこち", color(80, 220, 80), BASE_CARD_POINTS[2]),
    new RiceBrand("つやおうじ", color(220, 220, 80), BASE_CARD_POINTS[3])
  };
  playerLoadedRices = new int[riceBrandsInfo.length];
  aiLoadedRices = new int[riceBrandsInfo.length];
  marketStockKeep = new int[riceBrandsInfo.length];

  selectedAmounts = new int[riceBrandsInfo.length];
  riceBrandRanking = new int[riceBrandsInfo.length];
  gameState = new GameState();
  market = new Market();
  gameLogic = new GameLogic();
  player = new Player(PLAYER_POINT);
  ai = new AI(ENEMY_POINT);

  // UI系
  ui = new UI(gameState);
  leftPanel = new LeftPanel(ui);
  rightPanel = new RightPanel();
  popup = new Popup();
  cardVisual = new CardVisual();

  // ボタン系
  initButton();
}

void initButton() {
  // ========== 通常ボタンの初期化 ==========
  startButton = new NormalButton(width/2 - 50, 300, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "始める", 32, () -> {
    gameState.changeState(State.START);
  });
  describeButton = new NormalButton(width/2 - 50, 350, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "説明", 32, () -> {
    gameState.changeState(State.PLAYING);
  });
  endButton = new NormalButton(width/2 - 50, 400, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "終わる", 32, () -> {
    exit(); // ゲーム終了
  });

  // ========== 三角形ボタンの初期化 ==========
  minus1SelectedButton = new TriangleButton(1090, 300, true, () -> {
    if (selectedAmounts[selectedBrandId] > 0) {
      selectedAmounts[selectedBrandId]--;
    }
  });
  plus1SelectedButton = new TriangleButton(1150, 300, false, () -> {
    selectedAmounts[selectedBrandId]++;
  });

  brandPlus1Buttons = new TriangleButton[riceBrandsInfo.length];
  brandMinus1Buttons = new TriangleButton[riceBrandsInfo.length];

  for (int i = 0; i < riceBrandsInfo.length; i++) {
    final int index = i; // ラムダ式内で使うため
    brandMinus1Buttons[i] = new TriangleButton((width * 0.3) + 670, 216 + (i*60), true, () -> {
      if (selectedAmounts[riceBrandRanking[index]] > 0) {
        selectedAmounts[riceBrandRanking[index]]--;
        totalPrice -= riceBrandsInfo[riceBrandRanking[index]].point;
      }
    });
    brandPlus1Buttons[i] = new TriangleButton((width * 0.3) + 730, 216 + (i*60), false, () -> {
      selectedAmounts[riceBrandRanking[index]]++;
      totalPrice += riceBrandsInfo[riceBrandRanking[index]].point;
    });
  }

  // ========== 楕円形ボタンの初期化 ==========
  closePopupButton = new EllipseButton((width * 0.3) + 350, height - 100, 150, 70, color(0), color(100, 150, 230), color(85, 130, 215), "戻る", 32, () -> {
    closePopup();
  });
  closeEndPopupButton = new EllipseButton((width * 0.3) + 300, height - 280, 150, 70, color(0), color(100, 150, 230), color(85, 130, 215), "却下", 32, () -> {
    closePopup();
  });
  loadButton = new EllipseButton((width * 0.3) + 630, height - 100, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "提出", 32, () -> {
    // 提出処理をここに追加
    player.loadRice(selectedBrandId, selectedAmounts[selectedBrandId]);
    closePopup();
  });
  returnButton = new EllipseButton((width * 0.3) + 630, height - 100, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "返却", 32, () -> {
    // 提出処理をここに追加
  });
  turnEndButton = new EllipseButton((width * 0.3) + 650, height - 280, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "御意", 32, () -> {
    // 提出処理をここに追加
  });

  buyButton = new EllipseButton((width * 0.3) + 680, height - 170, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "購入", 32, () -> {
    // 購入処理をここに追加
    for (int i = 0; i < riceBrandsInfo.length; i++)
    player.buyRice(i, selectedAmounts[i]);
    closePopup();
  });

  playDescribeButton = new EllipseButton(width - 100, height - 180, 150, 70, color(0), color(100, 150, 230), color(85, 130, 215), "説明", 32, () -> {
    // 説明画面の表示処理をここに追加
    gameState.changeState(State.DESCRIBE);
  });
  submitButton = new EllipseButton(width - 100, height - 100, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "出荷", 32, () -> {
    gameState.playerShipRIce();
  });
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
  case DESCRIBE:
    ui.drawTitleScreen();
    break;
  case PLAYING:
    drawGameScreen();
    break;
  }

  // ポップアップ制御
  if (showingPopup && gameState.currentState == State.PLAYING) {
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
  if (keyPressed == true) {
    background(255);
    textFlag = 1;
  }
}

void mouseClicked() {
  if (gameState.currentState == State.PLAYING) {
    if (showingPopup) {
      if (popupType == "buy") {
        // 全てのブランドボタンをチェック
        for (int i = 0; i < brandPlus1Buttons.length; i++) {
          if (brandPlus1Buttons[i].onClicked()) {
            // 内部で既に実行済み
            return;
          } else if (brandMinus1Buttons[i].onClicked()) {
            // 内部で既に実行済み
            return;
          } else if (buyButton.onClicked()) {
            // 内部で既に実行済み
          }
        }
      } else if (popupType == "submit") {
        if (minus1SelectedButton.onClicked()) {
          // 内部で既に実行済み
        } else if (plus1SelectedButton.onClicked()) {
          // 内部で既に実行済み
        } else if (closePopupButton.onClicked()) {
          // 内部で既に実行済み
        } else if (loadButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "return") {
        if (returnButton.onClicked()) {
          // 内部で既に実行済み
        } else if (closePopupButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "turnEnd") {
        if (closeEndPopupButton.onClicked()) {
          // 内部で既に実行済み
        } else if (turnEndButton.onClicked()) {
          // 内部で既に実行済み
        }
      }
    } else {
      if (rightPanel.onBrand1Clicked()) {
        // 内部で既に実行済み
      } else if (playDescribeButton.onClicked()) {
        // 内部で既に実行済み
      } else if (submitButton.onClicked()) {
        // 内部で既に実行済み
      }
    }
  } else if (gameState.currentState == State.TITLE) {
    if (startButton.onClicked()) {
      // 内部で既に実行済み
    } else if (describeButton.onClicked()) {
      // 内部で既に実行済み
    } else if (endButton.onClicked()) {
      // 内部で既に実行済み
    }
  }
}
