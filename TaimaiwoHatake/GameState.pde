// ゲーム状態管理クラス

// TEST：テスト状態
// START：ゲーム開始前の状態
// PLAYING：ゲームプレイ中の状態
// FINISHED：ゲーム終了状態
enum State {
  TITLE,
  DESCRIBE,
  START,
  PLAYING,
  FINISHED,
}

class GameState {
  State currentState;
  
  // コンストラクタ
  GameState() {
    currentState = State.TITLE; // 初期状態をに設定
  }
  
  // 状態を変更するメソッド
  // 状態遷移、ページ切り替えを行う際に使用
  void changeState(State newState) {
    currentState = newState;
  }
}
