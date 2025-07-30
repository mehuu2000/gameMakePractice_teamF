// 弾丸クラス
class Bullet {
  float x, y;
  float vx, vy;
  float size;
  color col;
  float rotation = 0;
  
  Bullet(float x, float y, float vx, float vy, float size, color col) {
    this.x = x;
    this.y = y;
    this.vx = vx;
    this.vy = vy;
    this.size = size;
    this.col = col;
  }
  
  void update() {
    x += vx;
    y += vy;
    rotation += 0.1;
  }
  
  void display() {
    pushMatrix();
    translate(x, y);
    rotate(rotation);
    
    // 弾の見た目（星型の魔法弾）
    noStroke();
    fill(col);
    
    // グロー効果
    for (int i = 3; i > 0; i--) {
      fill(hue(col), saturation(col), brightness(col), 30);
      star(0, 0, size * (1 + i * 0.3), size * (1 + i * 0.3) * 1.5, 4);
    }
    
    // 本体
    fill(col);
    star(0, 0, size/2, size, 4);
    
    // 中心の光
    fill(0, 0, 100);
    ellipse(0, 0, size/3, size/3);
    
    popMatrix();
  }
  
  boolean isOffScreen() {
    return x < -50 || x > width + 50 || y < -50 || y > height + 50;
  }
}

// パーティクルクラス（エフェクト用）
class Particle {
  float x, y;
  float vx, vy;
  color col;
  float life = 1.0;
  float size;
  
  Particle(float x, float y, float angle, float speed, color col) {
    this.x = x;
    this.y = y;
    this.vx = cos(angle) * speed;
    this.vy = sin(angle) * speed;
    this.col = col;
    this.size = random(5, 15);
  }
  
  void update() {
    x += vx;
    y += vy;
    vx *= 0.95;
    vy *= 0.95;
    life -= 0.03;
  }
  
  void display() {
    noStroke();
    fill(hue(col), saturation(col), brightness(col), life * 100);
    ellipse(x, y, size * life, size * life);
  }
  
  boolean isDead() {
    return life <= 0;
  }
}