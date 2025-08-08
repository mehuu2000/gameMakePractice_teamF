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
  }

  //操作説明の描画
  //ここでは操作方法やルールを表示する
  //例えば、ゲームの目的や操作方法などを説明する
  void drawInstructions() {
  }
  void supplyLimitDisplay(int supplyLimit) {
    supplyLimitX = (supplyLimit / 10) * 10;
  }
}
