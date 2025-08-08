// ゲーム画面のUIを管理するクラス

class UI {
  int supplyLimitX;
  int startTime;
  int elapsedTime;  // 経過時間（ミリ秒）
  boolean startTimeSet = false;
  boolean[] isMessageDisplay = new boolean[]{false, false, false};

  GameState gameState;

  //コンストラクタ
  UI(GameState gameState) {
    this.gameState = gameState;
  }
  //タイトル画面の描画
  void drawTitleScreen() {
    fill(0);
    textSize(80);
    text("大米をはたけ！", width/2, 200);

    fill(255);
    startButton.display();
    describeButton.display();
    endButton.display();
  }
  //スタート画面の描画
  // スタート画面の描画
  void drawStartScreen(int supplyLimit) {
    if (!startTimeSet) {
      startTime = millis();
      startTimeSet = true;
    }
    elapsedTime = millis() - startTime;  // ← ここで毎回更新！
    supplyLimitDisplay(supplyLimit);

    if (elapsedTime >= 1000 && !isMessageDisplay[0]) {
      isMessageDisplay[0] = true;
    }

    if (elapsedTime >= 2000 && !isMessageDisplay[1]) {
      isMessageDisplay[1] = true;
    }

    if (elapsedTime >= 3000 && !isMessageDisplay[2]) {
      isMessageDisplay[2] = true;
    }

    if (elapsedTime >= 4000) {
      gameState.changeState(State.PLAYING);
      showPopup("year");
    }

    if (isMessageDisplay[0]) {
      textSize(60);
      fill(0);
      text("今回の市場の規模は", width/2, height/4);
    }

    if (isMessageDisplay[1]) {
      textSize(100);
      fill(255, 0, 0);
      text(supplyLimitX + " ～ " + (supplyLimitX + 10), width/2, height/2);
    }

    if (isMessageDisplay[2]) {
      fill(0);
      text("では始め！", width/2, (height/2 + height/4));
    }
  }

  //結果画面の描画
  void drawResultScreen() {
    fill(0);
    textSize(92);
    text("結果発表", width/2, 80);
    
    textSize(48);
    text("所持金", width/4 - 50, 300);
    text("所持金", (width - width/4) + 50, 300);
    
    textSize(100);
    text(player.wallet + "pt", width/4 - 50, 400);
    text(ai.wallet + "pt", (width - width/4) + 50, 400);
    
    fill(0, 0, 200);
    textSize(76);
    text("あなた", width/4 - 50, 200);
    
    fill(200, 0, 0);
    text("あいて", (width - width/4) + 50, 200);
    
    if(player.wallet >= ai.wallet){
      fill(0, 0, 200);
      textSize(180);
      text("勝利", width/2, 500);
      
      image(images[10], width/2 - 160, 120, 300, 300);
      
      fill(0);
      textSize(60);
      text("お見事！貴方こそ真の米マスターだ！", width/2, 650);
    } else {
      fill(200, 0, 0);
      textSize(180);
      text("敗北", width/2, 500);
      
      image(images[11], width/2 - 140, 120, 300, 300);
      
      fill(0);
      textSize(60);
      text("失敗は成功の大きな一歩である。", width/2, 650);
    }
  }

  //操作説明の描画
  //ここでは操作方法やルールを表示する
  //例えば、ゲームの目的や操作方法などを説明する
  void drawInstructions() {
    fill(0);
    textSize(40);
    textAlign(LEFT, CENTER);
    text("[ゲーム概要]", 50, 50);
    text("・大米をはたけ！とは", 50, 120);
    
    textSize(32);
    text("チーム「飯だ」が提供する、「令和の米騒動」をテーマとした", 90, 170);
    text("米取引シミュレーションカードゲーム。", 90, 220);
    text("ポイントを使用して米を買い、出荷する一連の流れを繰り返し", 90, 270);
    text("ゲーム終了時により多くのポイントを所持しているプレイヤーが勝者となる。", 90, 320);
    
    text("プレイヤーは各ターンごとに市場を確認し、利益が大きくなるように", 90, 420);
    text("米を出荷しなければならないほか、ランダムで発生する様々なイベントに", 90, 470);
    text("対応できる柔軟性も必要である。", 90, 520);
    
    titleButton.display();
    //overviewButton.display(); //デバッグ用
    systemButton.display();
    system2Button.display();
  }
  
  void drawSystemInstructions() {
    fill(0);
    textSize(40);
    textAlign(LEFT, CENTER);
    text("[システム説明1]", 50, 50);
    text("・大米をはたけ！とは", 50, 120);
    
    textSize(32);
    text("チーム「飯だ」が提供する、「令和の米騒動」をテーマとした", 90, 170);
    text("米取引シミュレーションカードゲーム。", 90, 220);
    text("ポイントを使用して米を買い、出荷する一連の流れを繰り返し", 90, 270);
    text("ゲーム終了時により多くのポイントを所持しているプレイヤーが勝者となる。", 90, 320);
    
    text("プレイヤーは各ターンごとに市場を確認し、利益が大きくなるように", 90, 420);
    text("米を出荷しなければならないほか、ランダムで発生する様々なイベントに", 90, 470);
    text("対応できる柔軟性も必要である。", 90, 520);
    
    titleButton.display();
    overviewButton.display();
    system2Button.display();
  }
  
  void drawSystem2Instructions() {
    fill(0);
    textSize(40);
    textAlign(LEFT, CENTER);
    text("[システム説明2]", 50, 50);
    text("・大米をはたけ！とは", 50, 120);
    
    textSize(32);
    text("チーム「飯だ」が提供する、「令和の米騒動」をテーマとした", 90, 170);
    text("米取引シミュレーションカードゲーム。", 90, 220);
    text("ポイントを使用して米を買い、出荷する一連の流れを繰り返し", 90, 270);
    text("ゲーム終了時により多くのポイントを所持しているプレイヤーが勝者となる。", 90, 320);
    
    text("プレイヤーは各ターンごとに市場を確認し、利益が大きくなるように", 90, 420);
    text("米を出荷しなければならないほか、ランダムで発生する様々なイベントに", 90, 470);
    text("対応できる柔軟性も必要である。", 90, 520);
    
    titleButton.display();
    overviewButton.display();
    systemButton.display();
  }
  
  void supplyLimitDisplay(int supplyLimit) {
    supplyLimitX = (supplyLimit / 10) * 10;
  }
}
