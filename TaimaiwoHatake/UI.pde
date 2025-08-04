// ゲーム画面のUIを管理するクラス

class UI {
  GameState gameState;
  
  // コンストラクタ
  UI(GameState gameState){
    this.gameState = gameState;
  }
  // タイトル画面の描画
  void drawTitleScreen() {
    fill(0);
    textSize(80);
    text("大米をはたけ！", width/2, 200);
    
    fill(255);
    
    funcButton(width/2 - 50 , 300, 100, 50, 20, 0, 240, "始める", 32,  () ->{
      gameState.changeState(State.PLAYING);
    });
    
    funcButton(width/2 - 50 , 350, 100, 50, 20, 0, 240, "説明", 32,  () ->{
      gameState.changeState(State.PLAYING);
    });
    
    funcButton(width/2 - 50 , 400, 100, 50, 20, 0, 240, "終わる", 32,  () ->{
      gameState.changeState(State.PLAYING);
    });
      
  }
  // スタート画面の描画
  void drawStartScreen(int playerPoint, int aiPoint) {
  }

  // 結果画面の描画
  void drawResultScreen() {
  }

  // 操作説明の描画
  // ここでは操作方法やルールを表示する
  // 例えば、ゲームの目的や操作方法などを説明する
  void drawInstructions() {
  }

  void funcButton(int x, int y, int width, int height, int radius, int textColor, int backgroundColor, String text, int size, Runnable func) {
    noStroke();
    fill(backgroundColor);
    rect(x, y, width, height, radius);
    fill(textColor);
    textSize(size);
    textAlign(CENTER, CENTER);
    text(text, x + width/2, y + height/2);
    if (mousePressed) {
      if (mouseX >= x && mouseX <= x + width &&
        mouseY >= y && mouseY <= y + height) {
        func.run();  // 関数実行！
      }
    }
  }
}
