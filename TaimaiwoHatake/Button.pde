// ButtonActionインターフェース
interface ButtonAction {
  void execute(); // ボタンがクリックされた時に実行されるメソッド
}

// FlexibleTriangleButtonクラスの定義
class TriangleButton {
  float x, y;
  float btnHeight = 30;
  float btnWidth = 30;
  boolean isLeft;
  color backgroundColor = color(21, 96, 130);
  color hoverColor = color(18, 82, 111);

  // 現在のボタンの色（描画時に使用）
  color currentColor;

  // ボタンが押された時に実行する処理
  ButtonAction clickAction;

  // コンストラクタ
  TriangleButton(float tempX, float tempY, boolean tempIsLeft, ButtonAction action) {
    x = tempX;
    y = tempY;
    isLeft = tempIsLeft;
    currentColor = backgroundColor; // 初期色は背景色
    clickAction = action;           // クリック時のアクションを設定
  }

  // ボタンを描画する
  void display() {
    // ホバー状態を一度だけ計算
    boolean hovered = isMouseOver();
    currentColor = hovered ? hoverColor : backgroundColor;

    fill(currentColor);
    noStroke();

    // 三角形の描画
    if (isLeft) {
      triangle(x, y,
        x - btnWidth, y + btnHeight/2,
        x, y + btnHeight);
    } else {
      triangle(x, y,
        x + btnWidth, y + btnHeight/2,
        x, y + btnHeight);
    }
  }

  // マウスカーソルがボタンの範囲内にあるかチェックする
  // 提供された当たり判定ロジックを使用
  boolean isMouseOver() {
    // 長方形の当たり判定で近似
    return mouseX >= x - (isLeft ? btnWidth : 0) &&
      mouseX <= x + (isLeft ? 0 : btnWidth) &&
      mouseY >= y &&
      mouseY <= y + btnHeight;
  }

  // ボタンがクリックされたかを判定し、アクションを実行する
  boolean onClicked() {
    if (isMouseOver()) {
      if (clickAction != null) {
        clickAction.execute(); // 定義されたアクションを実行
      }
      ses[2].play();
      ses[2].rewind();
      return true; // クリックされた
    }
    return false; // クリックされなかった
  }
}

class NormalButton {
  float x, y;
  float btnHeight;
  float btnWidth;
  int radius;
  int size;
  color textColor;
  color backgroundColor;
  color hoverColor;
  String text;

  // 現在のボタンの色（描画時に使用）
  color currentColor;

  // ボタンが押された時に実行する処理
  ButtonAction clickAction;
  
  // ボタンの有効/無効状態（デフォルトは有効）
  boolean isEnabled = true;

  // コンストラクタ
  NormalButton(float x_argument, float y_argument, float btnWidth_argument, float btnHeight_argument, int radius_argument, color textColor_argument, color backgroundColor_argument, color hoverColor_argument, String text_argument, int size_argument, ButtonAction action) {
    x = x_argument;
    y = y_argument;
    btnHeight = btnHeight_argument;
    btnWidth = btnWidth_argument;
    radius = radius_argument;
    textColor = textColor_argument;
    backgroundColor = backgroundColor_argument;
    hoverColor = hoverColor_argument;
    text = text_argument;
    size = size_argument;
    currentColor = backgroundColor; // 初期色は背景色
    clickAction = action;           // クリック時のアクションを設定
  }

  // ボタンを描画する
  void display() {
    // ホバー状態を一度だけ計算
    boolean hovered = isMouseOver();
    currentColor = hovered ? hoverColor : backgroundColor;

    fill(currentColor);
    noStroke();
    if(x == 0 && y == 0){
      fill(0, 0, 0, 0);
    }
    rect(x, y, btnWidth, btnHeight, radius);

    fill(textColor);
    if(x == 0 && y == 0){
      fill(0, 0, 0, 0);
    }
    textSize(size);
    textAlign(CENTER, CENTER);
    text(text, x + btnWidth/2, y + btnHeight/2);
  }

  // マウスカーソルがボタンの範囲内にあるかチェックする
  // 提供された当たり判定ロジックを使用
  boolean isMouseOver() {
    return mouseX >= x && mouseX <= x + btnWidth &&
      mouseY >= y && mouseY <= y + btnHeight;
  }

  // ボタンがクリックされたかを判定し、アクションを実行する
  boolean onClicked() {
    // ボタンが無効な場合は何もしない
    if (!isEnabled) {
      return false;
    }
    
    if (isMouseOver()) {
      if (clickAction != null) {
        clickAction.execute(); // 定義されたアクションを実行
      }
      ses[0].play();
      ses[0].rewind();
      return true; // クリックされた
    }
    return false; // クリックされなかった
  }
}

class EllipseButton {
    float x, y;  // 楕円の中心座標
    float btnWidth;   // 楕円の幅（水平方向の直径）
    float btnHeight;  // 楕円の高さ（垂直方向の直径）
    int size;
    color textColor;
    color backgroundColor;
    color hoverColor;
    String text;

    // 現在のボタンの色（描画時に使用）
    color currentColor;

    // ボタンが押された時に実行する処理
    ButtonAction clickAction;

    // コンストラクタ
    EllipseButton(float x_argument, float y_argument, float btnWidth_argument, float btnHeight_argument, color textColor_argument, color backgroundColor_argument, color hoverColor_argument, String text_argument, int size_argument, ButtonAction action) {
      x = x_argument;
      y = y_argument;
      btnWidth = btnWidth_argument;
      btnHeight = btnHeight_argument;
      textColor = textColor_argument;
      backgroundColor = backgroundColor_argument;
      hoverColor = hoverColor_argument;
      text = text_argument;
      size = size_argument;
      currentColor = backgroundColor; // 初期色は背景色
      clickAction = action;           // クリック時のアクションを設定
    }

    // ボタンを描画する
    void display() {
      if (isMouseOver()) {
        currentColor = hoverColor;
      } else {
        currentColor = backgroundColor;
      }

      fill(currentColor);
      noStroke();
      ellipse(x, y, btnWidth, btnHeight);  // 楕円を描画

      fill(textColor);
      textSize(size);
      textAlign(CENTER, CENTER);
      text(text, x, y);  // 楕円の中心にテキストを配置
    }

    // マウスカーソルがボタンの範囲内にあるかチェックする
    // 楕円の当たり判定の数式を使用
    boolean isMouseOver() {
      // 楕円の当たり判定の公式：((x-h)²/a²) + ((y-k)²/b²) <= 1
      float a = btnWidth / 2;   // 水平方向の半径
      float b = btnHeight / 2;  // 垂直方向の半径
      float dx = mouseX - x;    // 中心からの水平距離
      float dy = mouseY - y;    // 中心からの垂直距離

      return (dx * dx) / (a * a) + (dy * dy) / (b * b) <= 1;
    }

    // ボタンがクリックされたかを判定し、アクションを実行する
    boolean onClicked() {
      if (isMouseOver()) {
        if (clickAction != null) {
          clickAction.execute(); // 定義されたアクションを実行
        }
        ses[0].play();
        ses[0].rewind();
        return true; // クリックされた
      }
      return false; // クリックされなかった
    }
}
