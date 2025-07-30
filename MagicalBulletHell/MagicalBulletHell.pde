// 魔法少女弾幕ゲーム - メインファイル
Player player;
Enemy boss;
ArrayList<Bullet> playerBullets;
ArrayList<Bullet> enemyBullets;
ArrayList<Particle> particles;

int gameState = 0; // 0: タイトル, 1: ゲーム中, 2: ゲームオーバー, 3: クリア
int score = 0;
int highScore = 0;
float shakeAmount = 0;
PFont gameFont;

void setup() {
  size(600, 800);
  colorMode(HSB, 360, 100, 100);
  
  // 日本語フォントの設定
  gameFont = createFont("Arial", 32, true);
  textFont(gameFont);
  
  initGame();
}

void initGame() {
  player = new Player(width/2, height - 100);
  boss = new Enemy(width/2, 150);
  playerBullets = new ArrayList<Bullet>();
  enemyBullets = new ArrayList<Bullet>();
  particles = new ArrayList<Particle>();
  score = 0;
}

void draw() {
  // 背景（宇宙っぽい雰囲気）
  background(240, 30, 20);
  drawStars();
  
  // 画面揺れ効果
  if (shakeAmount > 0) {
    translate(random(-shakeAmount, shakeAmount), random(-shakeAmount, shakeAmount));
    shakeAmount *= 0.9;
  }
  
  switch(gameState) {
    case 0:
      drawTitle();
      break;
    case 1:
      updateGame();
      drawGame();
      break;
    case 2:
      drawGameOver();
      break;
    case 3:
      drawClear();
      break;
  }
}

void drawStars() {
  randomSeed(0);
  for (int i = 0; i < 50; i++) {
    float x = random(width);
    float y = random(height);
    float size = random(1, 3);
    noStroke();
    fill(0, 0, 100, 50);
    ellipse(x, y + frameCount * 0.5 % height, size, size);
  }
}

void updateGame() {
  // プレイヤー更新
  player.update();
  player.display();
  
  // ボス更新
  boss.update();
  boss.display();
  
  // プレイヤー弾の更新
  for (int i = playerBullets.size() - 1; i >= 0; i--) {
    Bullet b = playerBullets.get(i);
    b.update();
    b.display();
    
    // ボスとの当たり判定
    if (boss.checkHit(b.x, b.y, b.size)) {
      boss.hp -= 1;
      playerBullets.remove(i);
      score += 10;
      
      // ヒットエフェクト
      for (int j = 0; j < 10; j++) {
        particles.add(new Particle(b.x, b.y, random(TWO_PI), random(2, 5), color(random(300, 360), 80, 100)));
      }
      
      if (boss.hp <= 0) {
        gameState = 3;
        if (score > highScore) highScore = score;
      }
    } else if (b.isOffScreen()) {
      playerBullets.remove(i);
    }
  }
  
  // ボムエフェクトの描画と処理
  if (player.bombActive) {
    drawBombEffect();
    
    // ボム発動中は範囲内の敵弾を消去
    for (int i = enemyBullets.size() - 1; i >= 0; i--) {
      Bullet b = enemyBullets.get(i);
      float bombRadius = 150 + player.bombTimer;
      if (dist(player.x, player.y, b.x, b.y) < bombRadius) {
        enemyBullets.remove(i);
        // 消去エフェクト
        for (int j = 0; j < 3; j++) {
          particles.add(new Particle(b.x, b.y, random(TWO_PI), random(1, 3), color(60, 80, 100)));
        }
        score += 1;
      }
    }
  }
  
  // 敵弾の更新
  for (int i = enemyBullets.size() - 1; i >= 0; i--) {
    Bullet b = enemyBullets.get(i);
    b.update();
    b.display();
    
    // プレイヤーとの当たり判定（ボム発動中は無敵）
    if (!player.bombActive && player.checkHit(b.x, b.y, b.size)) {
      player.hp -= 1;
      enemyBullets.remove(i);
      shakeAmount = 10;
      
      // ダメージエフェクト
      for (int j = 0; j < 15; j++) {
        particles.add(new Particle(player.x, player.y, random(TWO_PI), random(3, 7), color(0, 80, 100)));
      }
      
      if (player.hp <= 0) {
        gameState = 2;
        if (score > highScore) highScore = score;
      }
    } else if (b.isOffScreen()) {
      enemyBullets.remove(i);
    }
  }
  
  // パーティクル更新
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    if (p.isDead()) {
      particles.remove(i);
    }
  }
  
  // UI表示
  drawUI();
}

void drawGame() {
  // ゲーム描画はupdateGameで処理
}

void drawUI() {
  // HP表示
  fill(0, 0, 100);
  textAlign(LEFT);
  text("HP: ", 10, 30);
  for (int i = 0; i < player.hp; i++) {
    fill(0, 80, 100);
    ellipse(50 + i * 20, 25, 15, 15);
  }
  
  // ボム表示
  fill(0, 0, 100);
  text("Bomb: ", 10, 55);
  for (int i = 0; i < player.bombs; i++) {
    fill(60, 80, 100);
    star(60 + i * 25, 50, 8, 12, 5);
  }
  
  // スコア表示
  fill(0, 0, 100);
  textAlign(RIGHT);
  text("Score: " + score, width - 10, 30);
  
  // ボスHP
  float hpRatio = (float)boss.hp / boss.maxHp;
  fill(0, 0, 30);
  rect(50, 80, width - 100, 20);
  fill(300, 80, 100);
  rect(50, 80, (width - 100) * hpRatio, 20);
}

void drawTitle() {
  fill(0, 0, 100);
  textAlign(CENTER);
  textSize(48);
  text("Magical Girl", width/2, height/2 - 100);
  text("Bullet Hell", width/2, height/2 - 40);
  
  textSize(24);
  text("Press SPACE to Start", width/2, height/2 + 50);
  
  textSize(16);
  text("Arrow Keys: Move", width/2, height/2 + 100);
  text("Z: Shoot", width/2, height/2 + 130);
  text("X: Bomb (2 uses)", width/2, height/2 + 160);
  
  text("High Score: " + highScore, width/2, height/2 + 200);
}

void drawGameOver() {
  fill(0, 0, 100);
  textAlign(CENTER);
  textSize(48);
  text("Game Over", width/2, height/2 - 50);
  
  textSize(24);
  text("Score: " + score, width/2, height/2 + 20);
  text("Press SPACE to Retry", width/2, height/2 + 80);
}

void drawClear() {
  fill(0, 0, 100);
  textAlign(CENTER);
  textSize(48);
  text("Stage Clear!", width/2, height/2 - 50);
  
  textSize(24);
  text("Score: " + score, width/2, height/2 + 20);
  text("Press SPACE to Play Again", width/2, height/2 + 80);
}

void keyPressed() {
  if (gameState == 1) {
    player.keyPressed();
  } else if (key == ' ') {
    gameState = 1;
    initGame();
  }
}

void keyReleased() {
  if (gameState == 1) {
    player.keyReleased();
  }
}

// ボムエフェクトの描画
void drawBombEffect() {
  pushMatrix();
  translate(player.x, player.y);
  
  // 波紋エフェクト
  float maxRadius = 150 + player.bombTimer;
  for (int i = 0; i < 3; i++) {
    float radius = maxRadius * (1 - i * 0.3) * (1 - player.bombTimer / 180.0);
    noFill();
    stroke(60, 80, 100, 100 - i * 30);
    strokeWeight(5 - i);
    ellipse(0, 0, radius * 2, radius * 2);
  }
  
  // 魔法陣
  rotate(frameCount * 0.05);
  stroke(60, 80, 100, 80);
  strokeWeight(2);
  for (int i = 0; i < 12; i++) {
    rotate(TWO_PI / 12);
    line(0, -maxRadius * 0.8, 0, -maxRadius);
  }
  
  // 中心の光
  fill(60, 20, 100, 50);
  noStroke();
  ellipse(0, 0, 50, 50);
  
  popMatrix();
}