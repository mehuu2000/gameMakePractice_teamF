// ゲーム画面のUIを管理するクラス

class UI {
  int supplyLimitX;
  int startTime;
  int elapsedTime;  // 経過時間（ミリ秒）
  boolean startTimeSet = true;
  boolean[] isMessageDisplay = new boolean[]{false, false, false};

  GameState gameState;

  // コンストラクタ
  UI(GameState gameState) {
    this.gameState = gameState;
  }
  // タイトル画面の描画
  void drawTitleScreen() {
    fill(0);
    textSize(80);
    text("大米をはたけ！", width/2, 200);

    fill(255);

    funcButton(width/2 - 50, 300, 100, 50, 20, 0, 240, 150, "始める", 32, () -> {
      gameState.changeState(State.START);
      startTimeSet = false;
    }
    );

    funcButton(width/2 - 50, 350, 100, 50, 20, 0, 240, 150, "説明", 32, () -> {
      gameState.changeState(State.PLAYING);
    }
    );

    funcButton(width/2 - 50, 400, 100, 50, 20, 0, 240, 150, "終わる", 32, () -> {
      gameState.changeState(State.PLAYING);
    }
    );
  }
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

    if (elapsedTime >= 1000) {
      gameState.changeState(State.PLAYING);
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

  // 結果画面の描画
  void drawResultScreen() {
  }

  // 操作説明の描画
  // ここでは操作方法やルールを表示する
  // 例えば、ゲームの目的や操作方法などを説明する
  void drawInstructions() {
  }

  void funcButton(int x, int y, int width, int height, int radius, int textColor, int backgroundColor, int hoverColor, String text, int size, Runnable func) {
    fill(backgroundColor);
    if (mouseX >= x && mouseX <= x + width &&
      mouseY >= y && mouseY <= y + height) {
      if (mousePressed) {
        func.run();  // 関数実行！
      }
      fill(hoverColor);
    }
    noStroke();
    rect(x, y, width, height, radius);
    fill(textColor);
    textSize(size);
    textAlign(CENTER, CENTER);
    text(text, x + width/2, y + height/2);
  }

  void supplyLimitDisplay(int supplyLimit) {
    supplyLimitX = (supplyLimit / 10) * 10;
  }
}
