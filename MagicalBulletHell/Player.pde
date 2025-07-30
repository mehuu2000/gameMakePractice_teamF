// プレイヤークラス（魔法少女）
class Player {
  float x, y;
  float speed = 5;
  float currentSpeed = 5;
  int hp = 5;
  int maxHp = 5;
  boolean[] keys = new boolean[7]; // LEFT, RIGHT, UP, DOWN, SHOOT, BOMB, FOCUS
  int shootCooldown = 0;
  float animTime = 0;
  int bombs = 2;
  int maxBombs = 2;
  boolean bombActive = false;
  int bombTimer = 0;
  boolean focusMode = false;
  float hitboxRadius = 5; // 当たり判定の半径
  
  Player(float x, float y) {
    this.x = x;
    this.y = y;
  }
  
  void update() {
    // 集弾モード（フォーカスモード）の処理
    focusMode = keys[6];
    currentSpeed = focusMode ? speed * 0.4 : speed; // 集弾モード時は40%の速度
    
    // 移動処理
    if (keys[0] && x > 20) x -= currentSpeed;
    if (keys[1] && x < width - 20) x += currentSpeed;
    if (keys[2] && y > 20) y -= currentSpeed;
    if (keys[3] && y < height - 20) y += currentSpeed;
    
    // 射撃処理
    if (keys[4] && shootCooldown <= 0) {
      shoot();
      shootCooldown = focusMode ? 3 : 5; // 集弾モード時は連射速度アップ
    }
    if (shootCooldown > 0) shootCooldown--;
    
    // ボム処理
    if (keys[5] && bombs > 0 && !bombActive) {
      activateBomb();
    }
    
    if (bombActive) {
      bombTimer--;
      if (bombTimer <= 0) {
        bombActive = false;
      }
    }
    
    animTime += 0.1;
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    
    // 魔法少女の描画（シンプルな可愛いデザイン）
    // 髪の毛
    fill(320, 70, 90); // ピンク色
    noStroke();
    // ツインテール
    ellipse(-15, -10, 20, 25);
    ellipse(15, -10, 20, 25);
    
    // 顔
    fill(20, 20, 95);
    ellipse(0, 0, 30, 30);
    
    // 目
    fill(0, 0, 100);
    ellipse(-7, -2, 8, 10);
    ellipse(7, -2, 8, 10);
    fill(0, 0, 0);
    ellipse(-7, -2, 3, 5);
    ellipse(7, -2, 3, 5);
    
    // 口
    stroke(0, 0, 50);
    noFill();
    arc(0, 5, 10, 8, 0, PI);
    
    // 体（ドレス）
    noStroke();
    fill(300, 60, 90); // 紫ピンク
    triangle(-15, 15, 15, 15, 0, 35);
    
    // 魔法の杖
    stroke(50, 80, 100);
    strokeWeight(3);
    line(20, 0, 25, -15);
    // 星
    fill(50, 80, 100);
    noStroke();
    pushMatrix();
    translate(25, -15);
    rotate(animTime);
    star(0, 0, 5, 10, 5);
    popMatrix();
    
    // オーラエフェクト
    noFill();
    stroke(300, 50, 100, 30);
    strokeWeight(2);
    ellipse(0, 0, 50 + sin(animTime) * 5, 50 + sin(animTime) * 5);
    
    popMatrix();
    
    // 当たり判定の可視化
    drawHitbox();
  }
  
  void drawHitbox() {
    // 集弾モード時は当たり判定をより明確に表示
    if (focusMode) {
      // 外側の円（警告エリア）
      noFill();
      stroke(0, 80, 100, 100);
      strokeWeight(2);
      ellipse(x, y, hitboxRadius * 6, hitboxRadius * 6);
      
      // 中間の円
      stroke(30, 80, 100, 150);
      strokeWeight(1.5);
      ellipse(x, y, hitboxRadius * 4, hitboxRadius * 4);
    }
    
    // コアの当たり判定（常に表示）
    fill(0, 80, 100, focusMode ? 200 : 100);
    noStroke();
    ellipse(x, y, hitboxRadius * 2, hitboxRadius * 2);
    
    // 中心点
    fill(0, 0, 100);
    ellipse(x, y, 2, 2);
  }
  
  void shoot() {
    if (focusMode) {
      // 集弾モード：前方集中ショット
      playerBullets.add(new Bullet(x, y - 20, 0, -12, 6, color(320, 80, 100)));
      playerBullets.add(new Bullet(x - 5, y - 20, 0, -12, 5, color(320, 80, 100)));
      playerBullets.add(new Bullet(x + 5, y - 20, 0, -12, 5, color(320, 80, 100)));
    } else {
      // 通常モード：3方向ショット
      playerBullets.add(new Bullet(x, y - 20, 0, -10, 5, color(300, 80, 100)));
      playerBullets.add(new Bullet(x - 10, y - 20, -2, -10, 5, color(300, 80, 100)));
      playerBullets.add(new Bullet(x + 10, y - 20, 2, -10, 5, color(300, 80, 100)));
    }
  }
  
  void activateBomb() {
    bombs--;
    bombActive = true;
    bombTimer = 180; // 3秒間の効果
  }
  
  boolean checkHit(float bx, float by, float bsize) {
    return dist(x, y, bx, by) < hitboxRadius + bsize/2;
  }
  
  void keyPressed() {
    if (keyCode == LEFT) keys[0] = true;
    if (keyCode == RIGHT) keys[1] = true;
    if (keyCode == UP) keys[2] = true;
    if (keyCode == DOWN) keys[3] = true;
    if (key == 'z' || key == 'Z') keys[4] = true;
    if (key == 'x' || key == 'X') keys[5] = true;
    if (keyCode == SHIFT) keys[6] = true;
  }
  
  void keyReleased() {
    if (keyCode == LEFT) keys[0] = false;
    if (keyCode == RIGHT) keys[1] = false;
    if (keyCode == UP) keys[2] = false;
    if (keyCode == DOWN) keys[3] = false;
    if (key == 'z' || key == 'Z') keys[4] = false;
    if (key == 'x' || key == 'X') keys[5] = false;
    if (keyCode == SHIFT) keys[6] = false;
  }
}

// 星形を描く関数
void star(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}
