// 敵キャラクタークラス（魔女っ子）
class Enemy {
  float x, y;
  float targetX, targetY;
  int hp = 200;
  int maxHp = 200;
  float animTime = 0;
  int phase = 0;
  int attackTimer = 0;
  int attackPattern = 0;
  
  Enemy(float x, float y) {
    this.x = x;
    this.y = y;
    this.targetX = x;
    this.targetY = y;
  }
  
  void update() {
    // スムーズな移動
    x = lerp(x, targetX, 0.05);
    y = lerp(y, targetY, 0.05);
    
    // アニメーション
    animTime += 0.05;
    
    // 攻撃パターン
    attackTimer++;
    
    // HPに応じてフェーズ変更
    if (hp < maxHp * 0.3) {
      phase = 2; // 激怒モード
    } else if (hp < maxHp * 0.6) {
      phase = 1; // 第2形態
    }
    
    // 攻撃実行
    executeAttack();
    
    // 移動パターン
    if (attackTimer % 120 == 0) {
      targetX = random(100, width - 100);
      targetY = random(100, 250);
    }
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    
    // 魔女っ子の描画
    // 髪の毛（長い紫の髪）
    fill(270, 70, 70); // 紫色
    noStroke();
    ellipse(0, -15, 40, 35);
    // サイドの髪
    arc(-20, 0, 30, 40, -PI/2, PI/2);
    arc(20, 0, 30, 40, PI/2, 3*PI/2);
    
    // 魔女帽子
    fill(270, 80, 40);
    triangle(-20, -25, 20, -25, 0, -45);
    rect(-25, -25, 50, 10);
    
    // 顔
    fill(20, 20, 95);
    ellipse(0, 0, 35, 35);
    
    // 目（つり目）
    fill(100, 70, 90); // 黄緑
    ellipse(-8, -3, 10, 8);
    ellipse(8, -3, 10, 8);
    fill(0, 0, 0);
    ellipse(-8, -3, 4, 4);
    ellipse(8, -3, 4, 4);
    
    // 不敵な笑み
    stroke(0, 0, 50);
    noFill();
    arc(0, 6, 15, 10, 0, PI);
    
    // 体（ドレス）
    noStroke();
    fill(270, 70, 50); // 濃い紫
    quad(-20, 20, 20, 20, 25, 45, -25, 45);
    
    // 魔法陣エフェクト
    pushMatrix();
    rotate(animTime);
    noFill();
    stroke(270, 80, 100, 50);
    strokeWeight(2);
    for (int i = 0; i < 6; i++) {
      rotate(TWO_PI / 6);
      line(0, -60, 0, -80);
    }
    ellipse(0, 0, 140, 140);
    popMatrix();
    
    // フェーズによる追加エフェクト
    if (phase >= 1) {
      // オーラ
      noFill();
      stroke(0, 80, 100, 40);
      strokeWeight(3);
      ellipse(0, 0, 80 + sin(animTime * 2) * 10, 80 + sin(animTime * 2) * 10);
    }
    
    if (phase >= 2) {
      // 怒りマーク
      fill(0, 80, 100);
      textSize(20);
      text("!", 30, -30);
    }
    
    popMatrix();
  }
  
  void executeAttack() {
    switch(phase) {
      case 0:
        // 基本攻撃パターン
        if (attackTimer % 30 == 0) {
          basicAttack();
        }
        if (attackTimer % 150 == 0) {
          circleAttack();
        }
        break;
        
      case 1:
        // 第2形態
        if (attackTimer % 20 == 0) {
          basicAttack();
        }
        if (attackTimer % 100 == 0) {
          spiralAttack();
        }
        if (attackTimer % 200 == 0) {
          circleAttack();
        }
        break;
        
      case 2:
        // 激怒モード
        if (attackTimer % 15 == 0) {
          basicAttack();
        }
        if (attackTimer % 60 == 0) {
          spiralAttack();
        }
        if (attackTimer % 120 == 0) {
          allDirectionAttack();
        }
        break;
    }
  }
  
  void basicAttack() {
    // プレイヤーに向かって3発
    float angle = atan2(player.y - y, player.x - x);
    float speed = 5;
    for (int i = -1; i <= 1; i++) {
      float a = angle + i * 0.2;
      enemyBullets.add(new Bullet(x, y + 20, cos(a) * speed, sin(a) * speed, 8, color(270, 80, 100)));
    }
  }
  
  void circleAttack() {
    // 円形弾幕
    int bulletCount = 16 + phase * 8;
    for (int i = 0; i < bulletCount; i++) {
      float angle = TWO_PI / bulletCount * i + animTime;
      float speed = 3;
      enemyBullets.add(new Bullet(x, y, cos(angle) * speed, sin(angle) * speed, 10, color(180, 80, 100)));
    }
  }
  
  void spiralAttack() {
    // 螺旋弾幕
    float baseAngle = animTime * 2;
    for (int i = 0; i < 5; i++) {
      float angle = baseAngle + i * TWO_PI / 5;
      float speed = 4;
      enemyBullets.add(new Bullet(x, y, cos(angle) * speed, sin(angle) * speed, 12, color(60, 80, 100)));
    }
  }
  
  void allDirectionAttack() {
    // 全方向爆発弾幕
    for (int i = 0; i < 36; i++) {
      float angle = TWO_PI / 36 * i;
      float speed = random(2, 6);
      enemyBullets.add(new Bullet(x, y, cos(angle) * speed, sin(angle) * speed, 8, color(0, 80, 100)));
    }
  }
  
  boolean checkHit(float bx, float by, float bsize) {
    return dist(x, y, bx, by) < 30 + bsize/2;
  }
}