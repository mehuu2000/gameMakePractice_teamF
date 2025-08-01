// 米カードクラス
String[] RICE_BRANDS = {"りょうおもい", "ほしひかり", "ゆめごこち", "つやおうじ"};

class RiceCard {
  int brandType; // 0-3
  int year; // 購入年
  float purchasePrice;
  
  RiceCard(int brandType) {
    this.brandType = brandType;
    this.year = currentTurn; // グローバル変数から現在のターンを取得
    this.purchasePrice = 10000; // デフォルト価格
  }
  
  // カード表示
  void display(float x, float y) {
    // カード背景
    stroke(0);
    strokeWeight(2);
    
    // ブランドごとの色設定
    switch(brandType) {
      case 0: fill(255, 200, 200); break; // りょうおもい - ピンク
      case 1: fill(200, 200, 255); break; // ほしひかり - 青
      case 2: fill(200, 255, 200); break; // ゆめごこち - 緑
      case 3: fill(255, 255, 200); break; // つやおうじ - 黄
    }
    rect(x, y, 80, 100, 5);
    
    // ブランド名
    fill(0);
    textAlign(CENTER);
    textSize(12);
    text(RICE_BRANDS[brandType], x + 40, y + 20);
    
    // 米のイラスト（簡易版）
    fill(255);
    ellipse(x + 40, y + 50, 30, 40);
    
    // 購入価格
    fill(0);
    textSize(10);
    text(int(purchasePrice/10000) + "万", x + 40, y + 85);
    
    // 古米表示
    int age = currentTurn - year;
    if (age >= 1) {
      fill(100, 50, 0);
      textSize(8);
      String ageText = "";
      for (int i = 0; i < min(age, 3); i++) {
        ageText += "古";
      }
      text(ageText + "米", x + 40, y + 95);
    }
  }
  
  // カードが古くなりすぎていないかチェック
  boolean isExpired() {
    return (currentTurn - year) >= 4;
  }
}