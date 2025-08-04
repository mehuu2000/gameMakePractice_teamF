// プレイヤーの動きを制御するクラス
// Broker.pdeから継承して使用

class Player extends Broker {
  Player(int wallet) {
    super(wallet);
  }
  // プレイヤーの行動を定義するメソッド
  void playerAction() {
    // プレイヤーの行動ロジックをここに実装
  }
}
