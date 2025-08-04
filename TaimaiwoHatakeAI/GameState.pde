// ゲーム状態管理クラス
enum State {
  START,
  PLAYING,
  GAME_OVER
}

class GameState {
  State currentState;
  
  GameState() {
    currentState = State.START;
  }
  
  void changeState(State newState) {
    currentState = newState;
  }
}