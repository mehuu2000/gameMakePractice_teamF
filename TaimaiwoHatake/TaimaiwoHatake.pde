PFont gameFont;
int textFlag = 0;

void setup() {
  size(1280, 720);
  background(255);

  // フォント設定
  gameFont = createFont("Meiryo", 16, true);
  textFont(gameFont);
  textAlign(CENTER, CENTER);
}

void draw() {
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
