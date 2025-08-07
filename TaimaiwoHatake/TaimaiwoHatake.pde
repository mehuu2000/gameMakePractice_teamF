import ddf.minim.*;

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

// ========== 音関係の変数 ==========
Minim minim;
String[] SE_NAMES = {"pon.wav", "titlecall.wav"};
String[] BGM_NAMES = {"maou_bgm_fantasy06.mp3", "maou_bgm_fantasy15.mp3",};
/*音の説明 / 0:ぽん-ボタン音
            1:たいまいをはたけ-タイトルコール
*/
AudioPlayer[] ses =  new AudioPlayer[SE_NAMES.length];
/*音の説明 / 0:荘厳め-タイトル
            1:戦闘曲-ゲーム
*/
AudioPlayer[] bgms = new AudioPlayer[BGM_NAMES.length];

// ========== ゲーム進行変数 ==========
int currentTurn = 1;
int maxTurns = 11; // 要相談

// ========== UI状態変数 ==========
boolean showingPopup = false; // ポップアップ表示フラグ
String popupType = ""; // ポップアップの種類
int selectedBrandId = 0; // 選択されたブランド(買い付けフェーズなど)
int totalPrice = 0; // 購入合計金額

// ========== 定数 ==========
final String[] RICE_BRANDS = {"りょうおもい", "ほしひかり", "ゆめごこち", "つやおうじ"};
final int WINDOW_WIDTH = 1280; // ウィンドウ幅
final int WINDOW_HEIGHT = 720; // ウィンドウ高さ
final int PLAYER_POINT = 500; // プレイヤー初期所持金
final int ENEMY_POINT = 500; // AI初期所持金
final float LEFT_PANEL_WIDTH = 0.3;   // 左パネルの幅（30%）
final float RIGHT_PANEL_WIDTH = 0.7;  // 右パネルの幅（70%）
final int BASE_CARD_POINT = 100; // 基本のカードポイント

// ========== 変数（変更可能） ==========
RiceBrand[] riceBrandsInfo;
int[] selectedAmounts; // 選択されたカードの数量。インデックス = ブランドID
int[] riceBrandRanking; // ブランドの供給数ランキング（重複なし）

int sumBrandCount = 0; // 総数を管理する変数
boolean isFirst = false; // 初回フラグ

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
}

void settings() {
  size(WINDOW_WIDTH, WINDOW_HEIGHT);
}

void setup() {
  background(255);

  // フォント設定
  gameFont = createFont("fonts/HGSGyoshotai", 16, true);
  textFont(gameFont);
  textAlign(CENTER, CENTER);

  initGame();
}

// ゲーム初期化
// ここでゲームの初期状態を設定
void initGame() {
  riceBrandsInfo = new RiceBrand[] {
    new RiceBrand("りょうおもい", color(220, 80, 80), BASE_CARD_POINT),
    new RiceBrand("ほしひかり", color(80, 80, 220), BASE_CARD_POINT),
    new RiceBrand("ゆめごこち", color(80, 220, 80), BASE_CARD_POINT),
    new RiceBrand("つやおうじ", color(220, 220, 80), BASE_CARD_POINT)
  };

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
  
  // 音系
  initSound();
  
  // タイトルコール
  ses[1].play();
  ses[1].rewind();
  // タイトルBGM（他のbgmは止める）
  bgms[1].pause();
  bgms[0].loop();
  bgms[0].rewind();
  currentTurn = 1;
}

void initButton() {
  // ========== 通常ボタンの初期化 ==========
  startButton = new NormalButton(width/2 - 50, 300, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "始める", 32, () -> {
    gameState.changeState(State.START);
  });
  describeButton = new NormalButton(width/2 - 50, 350, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "説明", 32, () -> {
    bgms[0].pause();
    bgms[1].loop();
    bgms[1].rewind();
    gameState.changeState(State.PLAYING);
  });
  endButton = new NormalButton(width/2 - 50, 400, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "終わる", 32, () -> {
    stop(); // ゲーム終了前の処理
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
    // 出荷処理をここに追加
    player.shipRice();
  });
}

// ========== 音関係の初期化 ==========
void initSound(){
  minim = new Minim(this);
  for(int i = 0; i < bgms.length; i++)
    bgms[i] = minim.loadFile("sounds/bgms/" + BGM_NAMES[i]);
  for(int i = 0; i < ses.length; i++)
    ses[i] = minim.loadFile("sounds/ses/" + SE_NAMES[i]);
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

//スケッチが正常に終了した時に実行される関数
void stop() {
  for(int i = 0; i < bgms.length; i++)
    bgms[i].close();
  for(int i = 0; i < bgms.length; i++)
    ses[i].close();
  minim.stop();
  super.stop();
}
