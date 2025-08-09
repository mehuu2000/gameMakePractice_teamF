import ddf.minim.*;

PFont gameFont;
PImage[] images;

// ========== ゲームオブジェクト ==========
GameState gameState;
Market market;
Player player;
AI ai;
GameLogic gameLogic;
EventManager eventManager;

// UI系オブジェクト
UI ui;
LeftPanel leftPanel;
RightPanel rightPanel;
Popup popup;
CardVisual cardVisual;

// ボタン系オブジェクト
NormalButton startButton; // スタートボタン
NormalButton describeButton; // 説明ボタン
NormalButton titleButton; // タイトルへ戻るボタン
NormalButton systemButton; // システム説明1へ移るボタン
NormalButton system2Button; // システム説明2へ移るボタン
NormalButton overviewButton; // 概要（説明の初期ページ）へ移るボタン
NormalButton endButton; // 終了ボタン
NormalButton nextButton; //次のポップアップに移動するボタン

TriangleButton plus1SelectedButton; // 現在の選択ブランドの選択数を1増やす
TriangleButton minus1SelectedButton; // 現在の選択ブランドの選択数を1減らす

TriangleButton[] brandPlus1Buttons; // 購入の際に特定のブランドの選択数を1増やすボタン
TriangleButton[] brandMinus1Buttons; // 購入の際に特定のブランドの選択数を1減らすボタン

EllipseButton closePopupButton; // ポップアップを閉じるボタン（通常）
EllipseButton closeBuyPopupButton; // 購入ポップアップを閉じるボタン
EllipseButton closeEndPopupButton; // ポップアップを閉じるボタン（却下ボタン）
EllipseButton loadButton; // ポップアップの提出ボタン
EllipseButton returnButton; // ポップアップの返却ボタン
EllipseButton turnEndButton; // ターン終了を確定するボタン

EllipseButton buyButton; // 購入ボタン

EllipseButton playDescribeButton; // 説明画面に移動するボタン
EllipseButton submitButton; // 出荷ボタン
EllipseButton buyPopupButton; // 購入ポップアップを表示するボタン

// ========== 音関係の変数 ==========
Minim minim;
String[] SE_NAMES = {"button70.mp3", "titlecall.wav", "wood-block01.mp3", "カードを台の上に出す.mp3", "レジ.mp3"};
String[] BGM_NAMES = {"maou_bgm_fantasy06.mp3", "真剣勝負-ロング.mp3",};
/*音の説明 / 0:ぽん-ボタン音
            1:たいまいをはたけ-タイトルコール
            2:ぽんーボタン音
            3:シャーカード提出音
            4:ジャキンーお金音
*/
AudioPlayer[] ses =  new AudioPlayer[SE_NAMES.length];
/*音の説明 / 0:荘厳め-タイトル
            1:戦闘曲-ゲーム
*/
AudioPlayer[] bgms = new AudioPlayer[BGM_NAMES.length];

// ========== ゲーム進行変数 ==========
int currentTurn = 1;
int maxTurn = 4 * 3 + 2; // 最大ターン数(5年 + 2シーズン(売却のため))
int[] currentYear_season = {1, 0}; // 年と季節を管理する配列。年, 季節(0:秋, 1:冬, 2:春, 3:夏, )

// ========== UI状態変数 ==========
boolean showingPopup = false; // ポップアップ表示フラグ
String popupType = ""; // ポップアップの種類
String[] popupQueue = new String[10]; // ポップアップのキュー（最大10個）
int popupQueueSize = 0; // キューに入っているポップアップの数
int currentPopupIndex = 0; // 現在表示中のポップアップのインデックス
int selectedBrandId = 0; // 選択されたブランド(買い付けフェーズなど)
int totalPrice = 0; // 購入合計金額
boolean isFromBuyScreen = false; // 購入画面から確認画面へ遷移したか

// 購入確認用の一時保存変数
int[] tempSelectedAmounts; // 購入数の一時保存
int tempTotalPrice = 0; // 合計金額の一時保存

// 集計結果で使用する変数
int playerProfit = 0; // プレイヤーの利益
int aiProfit = 0; // AIの利益
int[] playerLoadedRices; // プレイヤーが前シーズンで出荷した米の数
int[] aiLoadedRices; // AIが前シーズンで出荷した米の数
int[] marketStockKeep; // 出荷前の在庫を保持するための配列
int[] marketStockAfterShip; // 出荷直後（消費前）の在庫を保持するための配列
int[] marketPriceKeep; // 出荷直前の価値を保持するための配列
int[] riceBrandKeepPrice; // 各ブランドの価値を保持するための配列


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
final int LOWER_LIMIT_RICE_POINT= 100; // 米の下限価格
final int PHOTO_SHEETS = 20; //画像の上限数

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
void updateEventEffect(float effect) {
  eventEffect = int(eventEffect * effect);
}

// イベントの倍率をリセット
void resetEventEffect() {
  eventEffect = baseEventEffect; // デフォルトの効果倍率にリセット
}

// 現在の年と季節を返す関数
int[] getCurrentYear() {
  int[] year_season = new int[currentYear_season.length];
  year_season[0] = int((currentTurn-1)/4) + 1; // 年
  year_season[1] = (currentTurn - 1) % 4; // 季節(0:秋, 1:冬, 2:春, 3:夏)
  return year_season;
}

// ========== ポップアップ管理 ==========
void showPopup(String type) {
  // キューに追加
  if (popupQueueSize < 10) {
    popupQueue[popupQueueSize] = type;
    popupQueueSize++;
  }
  
  // 最初のポップアップの場合、表示を開始
  if (popupQueueSize == 1) {
    showingPopup = true;
    popupType = popupQueue[0];
    currentPopupIndex = 0;
    resetSelectedAmounts();
    // 新しいキューの開始時にタイマーをリセット
    popup.yearPopupTimerSet = false;
    popup.yearPopupStartTime = 0;
    popup.popupClosing = false;
    popup.currentNewsIndex = 0;  // 予報のインデックスもリセット
  }
}

void closePopup() {
  // nextButtonを無効化（次のポップアップのため）
  nextButton.isEnabled = false;
  
  // 次のポップアップがあるかチェック
  currentPopupIndex++;
  if (currentPopupIndex < popupQueueSize) {
    // 次のポップアップを表示
    popupType = popupQueue[currentPopupIndex];
    popup.yearPopupTimerSet = false; // タイマーリセット
    popup.yearPopupStartTime = 0; // タイマー開始時刻もリセット
    popup.popupClosing = false; // 閉じる処理フラグもリセット
  } else {
    // 全てのポップアップが終了
    showingPopup = false;
    popupType = "";
    popupQueueSize = 0;
    currentPopupIndex = 0;
    selectedBrandId = -1;
    resetSelectedAmounts();
    sumBrandCount = 0;
    isFirst = false;
    totalPrice = 0;
    popup.popupClosing = false; // 閉じる処理フラグもリセット
    
    // 全ポップアップ終了後の処理
    if (popupQueue[0] != null && popupQueue[0].equals("countStart")) {
      // endTurn関連のポップアップが終わったら次のターンへ
      // キューをクリアしてから次のターンへ
      for (int i = 0; i < 10; i++) {
        popupQueue[i] = null;
      }
      gameState.finishEndTurn();
    }
  }
}

// ポップアップキューをクリア
void clearPopupQueue() {
  popupQueueSize = 0;
  currentPopupIndex = 0;
  for (int i = 0; i < 10; i++) {
    popupQueue[i] = null;
  }
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
    new RiceBrand("りょうおもい", color(80, 220, 80), BASE_CARD_POINTS[0]),
    new RiceBrand("ほしひかり", color(80, 80, 220), BASE_CARD_POINTS[1]),
    new RiceBrand("ゆめごこち", color(220, 80, 80), BASE_CARD_POINTS[2]),
    new RiceBrand("つやおうじ", color(220, 220, 80), BASE_CARD_POINTS[3])
  };
  playerLoadedRices = new int[riceBrandsInfo.length];
  aiLoadedRices = new int[riceBrandsInfo.length];
  marketStockKeep = new int[riceBrandsInfo.length];
  marketStockAfterShip = new int[riceBrandsInfo.length];
  marketPriceKeep = new int[riceBrandsInfo.length];
  riceBrandKeepPrice = new int[riceBrandsInfo.length];

  selectedAmounts = new int[riceBrandsInfo.length];
  tempSelectedAmounts = new int[riceBrandsInfo.length]; // 一時保存配列の初期化
  riceBrandRanking = new int[riceBrandsInfo.length];
  market = new Market();
  cardVisual = new CardVisual();
  gameLogic = new GameLogic();
  player = new Player(PLAYER_POINT);
  ai = new AI(ENEMY_POINT);
  effectManager = new EventEffectManager();  // イベント効果管理の初期化
  eventManager = new EventManager();
  gameState = new GameState();
  
  // その時の供給在庫を更新
  marketStockKeep = market.marketStock.clone();
  
  // UI系
  ui = new UI(gameState);
  leftPanel = new LeftPanel(ui);
  rightPanel = new RightPanel();
  popup = new Popup();
  cardVisual = new CardVisual();
  images = new PImage[PHOTO_SHEETS]; // 画像配列を初期化
  
  //ここに images[x] = loadImage("〇〇.png");  の形で画像を指定してください
  images[0] = loadImage("truck.png");
  images[1] = loadImage("leftArrow.png");
  images[2] = loadImage("wareHouse.png");
  images[3] = loadImage("enemy.png");
  images[4] = loadImage("topview_car_truck_player.png");
  images[5] = loadImage("topview_car_truck_enemy.png");
  images[6] = loadImage("background.png");
  images[7] = loadImage("background_winter.jpeg");
  images[8] = loadImage("background_spring.jpeg");
  images[9] = loadImage("background_summer.jpeg");
  images[10] = loadImage("win.png");
  images[11] = loadImage("lose.png");
  
  
  
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
    bgms[0].pause();
    bgms[1].loop();
    bgms[1].rewind();
  });
  describeButton = new NormalButton(width/2 - 50, 350, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "説明", 32, () -> {
    //bgms[0].pause();
    //bgms[1].loop();
    //bgms[1].rewind();
    gameState.changeState(State.DESCRIBE);
  });
  endButton = new NormalButton(width/2 - 50, 400, 100, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "終わる", 32, () -> {
    stop(); // ゲーム終了前の処理
    exit(); // ゲーム終了
  });
  titleButton = new NormalButton(50, 650, 160, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "タイトルへ", 32, () -> {
    gameState.changeState(State.TITLE);
  });
  overviewButton = new NormalButton(width/2 - 180, 650, 190, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "ゲーム概要へ", 32, () -> {
    gameState.changeState(State.DESCRIBE);
  });
  systemButton = new NormalButton(width/2 + 70, 650, 235, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "システム説明[1]", 32, () -> {
    gameState.changeState(State.DESCRIBE2);
  });
  system2Button = new NormalButton(width - 280, 650, 235, 50, 20, color(0, 0, 0), color(240, 240, 240), color(220, 220, 220), "システム説明[2]", 32, () -> {
    gameState.changeState(State.DESCRIBE3);
  });
  nextButton = new NormalButton(0, 0, width, height, 0, color(0, 0, 0), color(0, 0, 0), color(0, 0, 0), "", 32, () -> {
    closePopup();
  });

  // ========== 三角形ボタンの初期化 ==========
  minus1SelectedButton = new TriangleButton(1090, 300, true, () -> {
    if (selectedAmounts[selectedBrandId] > 0) {
      selectedAmounts[selectedBrandId]--;
    }
  });
  plus1SelectedButton = new TriangleButton(1150, 300, false, () -> {
    if (popupType == "submit" && selectedAmounts[selectedBrandId] < player.getSumHandRice(selectedBrandId)) {
      selectedAmounts[selectedBrandId]++;
    }
    if (popupType == "return" && selectedAmounts[selectedBrandId] < player.getSumLoadRice(selectedBrandId)) {
      selectedAmounts[selectedBrandId]++;
    }
  });

  brandPlus1Buttons = new TriangleButton[riceBrandsInfo.length];
  brandMinus1Buttons = new TriangleButton[riceBrandsInfo.length];

  for (int i = 0; i < riceBrandsInfo.length; i++) {
    final int index = i; // ラムダ式内で使うため
    brandMinus1Buttons[i] = new TriangleButton((width * 0.3) + 670, 216 + (i*60), true, () -> {
      if (selectedAmounts[riceBrandRanking[index]] > 0) {
        selectedAmounts[riceBrandRanking[index]]--;
        float effectMultiplier = 1.0;
        if (effectManager != null) {
          effectMultiplier = effectManager.getBrandBuyPriceMultiplier(riceBrandRanking[index]);
        }
        totalPrice -= int(riceBrandsInfo[riceBrandRanking[index]].point * RICE_BUY_RATIO * effectMultiplier);
      }
    });
    brandPlus1Buttons[i] = new TriangleButton((width * 0.3) + 730, 216 + (i*60), false, () -> {
      selectedAmounts[riceBrandRanking[index]]++;
      float effectMultiplier = 1.0;
      if (effectManager != null) {
        effectMultiplier = effectManager.getBrandBuyPriceMultiplier(riceBrandRanking[index]);
      }
      totalPrice += int(riceBrandsInfo[riceBrandRanking[index]].point * RICE_BUY_RATIO * effectMultiplier);
    });
  }

  // ========== 楕円形ボタンの初期化 ==========
  closePopupButton = new EllipseButton((width * 0.3) + 350, height - 100, 150, 70, color(0), color(100, 150, 230), color(85, 130, 215), "戻る", 32, () -> {
    closePopup();
  });
  closeBuyPopupButton = new EllipseButton((width * 0.3) + 600, height - 170, 150, 70, color(0), color(100, 150, 230), color(85, 130, 215), "戻る", 32, () -> {
    closePopup();
  });
  closeEndPopupButton = new EllipseButton((width * 0.3) + 300, height - 280, 150, 70, color(0), color(100, 150, 230), color(85, 130, 215), "却下", 32, () -> {
    closePopup();
  });
  loadButton = new EllipseButton((width * 0.3) + 630, height - 100, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "積む", 32, () -> {
    gameState.playerLoadRice();
  });
  returnButton = new EllipseButton((width * 0.3) + 630, height - 100, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "返却", 32, () -> {
    gameState.playerBackRice();
  });
  turnEndButton = new EllipseButton((width * 0.3) + 650, height - 280, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "御意", 32, () -> {
    // 購入画面からか出荷のみかで処理を分岐
    if (isFromBuyScreen) {
      gameState.confirmBuyAndShip();
    } else {
      gameState.confirmShipOnly();
    }
  });

  buyButton = new EllipseButton((width * 0.3) + 760, height - 170, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "購入", 32, () -> {
    gameState.buyAndShip();
  });

  playDescribeButton = new EllipseButton(width - 100, height - 40, 105, 49, color(0), color(100, 150, 230), color(85, 130, 215), "説明", 28, () -> {
    // 説明画面の表示処理をここに追加
    gameState.changeState(State.DESCRIBE);
  });
  buyPopupButton = new EllipseButton(width - 95, height - 150, 150, 70, color(0), color(100, 230, 150), color(85, 215, 130), "仕入れ", 32, () -> {
   showPopup("buy");
  });
  submitButton = new EllipseButton((width * 0.3) + 100, height/2 - 80, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "出荷", 32, () -> {
    gameState.playerShipRIce();
  });
}

// ========== 音関係の初期化 ==========
void initSound(){
  minim = new Minim(this);
  for(int i = 0; i < bgms.length; i++)
    bgms[i] = minim.loadFile("sounds/bgms/" + BGM_NAMES[i]);
  for(int i = 0; i < ses.length; i++)
    ses[i] = minim.loadFile("sounds/ses/" + SE_NAMES[i]);
    
  bgms[0].setGain(-10);
  bgms[1].setGain(-7);
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
    ui.drawInstructions();
    break;
  case DESCRIBE2:
    ui.drawSystemInstructions();
    break;
  case DESCRIBE3:
    ui.drawSystem2Instructions();
    break;
  case PLAYING:
    background(100);
    tint(255, 150);
    if(currentYear_season[1] == 0){
      image(images[6], 0, 0);
    } else if(currentYear_season[1] == 1){
      image(images[7], 0, 0, 1280, 720);
    } else if(currentYear_season[1] == 2){
      image(images[8], 0, 0, 1280, 720);
    } else if(currentYear_season[1] == 3){
      image(images[9], 0, 0, 1280, 720);
    }
    noTint();
    drawGameScreen();
    break;
  case FINISHED:
    ui.drawResultScreen();
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
          }
        }
        // 購入関連ボタンをループの外でチェック
        if (buyButton.onClicked()) {
          // 内部で既に実行済み
        } else if (closeBuyPopupButton.onClicked()) {
          // 内部で既に実行済み
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
        } else if (minus1SelectedButton.onClicked()) {
          // 内部で既に実行済み
        } else if (plus1SelectedButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "turnEnd") {
        if (closeEndPopupButton.onClicked()) {
          // 内部で既に実行済み
        } else if (turnEndButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "carry") {
        if (nextButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "cell") {
        if (nextButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "fluctuation") {
        if (nextButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "profit") {
        if (nextButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "event") {
        if (nextButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "news") {
        if (nextButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "missed") {
        if (nextButton.onClicked()) {
          // 内部で既に実行済み
        }
      } else if (popupType == "eventHistory") {
        // イベント履歴ポップアップ用の戻るボタンのクリック判定（右側配置）
        float buttonX = width - 280;
        float buttonY = height - 150;
        float buttonWidth = 150;
        float buttonHeight = 60;
        
        if (mouseX >= buttonX - buttonWidth/2 && mouseX <= buttonX + buttonWidth/2 &&
            mouseY >= buttonY - buttonHeight/2 && mouseY <= buttonY + buttonHeight/2) {
          closePopup();
        }
      } else if (popupType == "forecastHistory") {
        // 予報履歴ポップアップ用の戻るボタンのクリック判定（右側配置）
        float buttonX = width - 280;
        float buttonY = height - 150;
        float buttonWidth = 150;
        float buttonHeight = 60;
        
        if (mouseX >= buttonX - buttonWidth/2 && mouseX <= buttonX + buttonWidth/2 &&
            mouseY >= buttonY - buttonHeight/2 && mouseY <= buttonY + buttonHeight/2) {
          closePopup();
        }
      }
    } else {
      if (rightPanel.onEventBoxClicked()) {
        // 内部で既に実行済み
      } else if (rightPanel.onNewsBoxClicked()) {
        // 内部で既に実行済み
      } else if (rightPanel.onBrand1Clicked()) {
        // 内部で既に実行済み
      } else if (rightPanel.onLoadBrandClicked()) {
        // 内部で既に実行済み
      } else if (playDescribeButton.onClicked()) {
        // 内部で既に実行済み
      } else if (submitButton.onClicked()) {
        // 内部で既に実行済み
      } else if (buyPopupButton.onClicked()) {
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
  } else if (gameState.currentState == State.DESCRIBE) {
    if (titleButton.onClicked()) {
      // 内部で既に実行済み
    } else if (overviewButton.onClicked()) {
      // 内部で既に実行済み
    } else if (systemButton.onClicked()) {
      // 内部で既に実行済み
    } else if (system2Button.onClicked()) {
      // 内部で既に実行済み
    }
  } else if (gameState.currentState == State.DESCRIBE2) {
    if (titleButton.onClicked()) {
      // 内部で既に実行済み
    } else if (overviewButton.onClicked()) {
      // 内部で既に実行済み
    } else if (systemButton.onClicked()) {
      // 内部で既に実行済み
    } else if (system2Button.onClicked()) {
      // 内部で既に実行済み
    }
  } else if (gameState.currentState == State.DESCRIBE3) {
    if (titleButton.onClicked()) {
      // 内部で既に実行済み
    } else if (overviewButton.onClicked()) {
      // 内部で既に実行済み
    } else if (systemButton.onClicked()) {
      // 内部で既に実行済み
    } else if (system2Button.onClicked()) {
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
