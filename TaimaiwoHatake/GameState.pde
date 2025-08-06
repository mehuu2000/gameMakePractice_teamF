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
  FINISHED
}

class GameState {
  State currentState;
  
  // コンストラクタ
  GameState() {
    currentState = State.TITLE; // 初期状態をTITLEに設定
  }
  
  // 状態を変更するメソッド
  // 状態遷移、ページ切り替えを行う際に使用
  void changeState(State newState) {
    currentState = newState;
  }

  // 米購入関数 TaimaiwoHatakeの
  // buyButton = new EllipseButton((width * 0.3) + 680, height - 170, 150, 70, color(0), color(230, 150, 100), color(215, 130, 85), "購入", 32, () -> {
  //   // 購入処理をここに追加
  //   for (int i = 0; i < riceBrandsInfo.length; i++)
  //     player.buyRice(i, selectedAmounts[i]);
  //   closePopup();
  // });
  // で使う
  void forBuyRice() {
    if (player.wallet - totalPrice < 0) {
      return; // 残金が足りない場合は何もしない
    }
    for (int i = 0; i < riceBrandsInfo.length; i++)
      player.buyRice(i, selectedAmounts[i]);
    closePopup();
  }

  // 提出関数 ボタンでつかうよ
  void playerLoadRice() {
    player.loadRice(selectedBrandId, selectedAmounts[selectedBrandId]);
    closePopup();
  }

  // 返却関数 ボタンでつかうよ
  void playerBackRice() {
    player.backRice(selectedBrandId, selectedAmounts[selectedBrandId]);
    closePopup();
  }

  // 手札の米をクリックした時(提出)
  void selectBrandSubmit(int brandId) {
    selectedBrandId = brandId;
    showPopup("submit");
  }

  // 場に出してる米をクリックした時(返却)
  void selectBrandBack() {
    selectedBrandId = brandId;
    showPopup("back");
  }

  // 選択した手札のブランドの枚数を返す(ポップアップの総数用)
  void handBrandCount() {
    if (!isFirst) {
        sumBrandCount = player.getSumHandRice(selectedBrandId);
        isFirst = true;
    }
  }

  // 選択した出荷場のブランドの枚数を返す(ポップアップの総数用)
  void loadBrandCount() {
    if (!isFirst) {
        sumBrandCount = player.getSumLoadRice(selectedBrandId);
        isFirst = true;
    }
  }
}
