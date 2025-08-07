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

  // 出荷関数 ボタンでつかうよ
  void playerShipRIce() {
    player.shipRice();
    closePopup();
    
    endTurn(); // 出荷後にターンを進める
  }

  // 手札の米をクリックした時(提出)
  void selectBrandSubmit(int brandId) {
    selectedBrandId = brandId;
    showPopup("submit");
  }

  // 場に出してる米をクリックした時(返却)
  void selectBrandBack(int brandId) {
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

  // ========== ターン管理 ==========
  void endTurn() {
    if (currentTurn > maxTurns) {
      // ゲーム終了処理、結果画面の表示など
      // もしくは次ターン米騒動?
    }
    // 出荷処理
    ai.shipRice(); // AIの出荷処理

    // ブローカーの出荷状態を保存 (プレイヤーの利益表示ポップアップで使用)
    for (int i=0; i<riceBrandsInfo.length; i++) {
      playerLoadedRices[i] = player.getSumLoadRice(i); // プレイヤーの出荷状態を保存
      aiLoadedRices[i] = ai.getSumLoadRice(i); // AIの出荷状態を保存
    }

    market.updateBrandPoint(); // 市場のブランドポイントを更新
    market.getBrandRanking(); // ブランドの価値ランキングを更新

    // 利益処理 (プレイヤーの利益表示ポップアップでも使用される)
    playerProfit = player.sellRice(); // プレイヤーの利益計算
    aiProfit = ai.sellRice(); // AIの利益計算

    // 利益表示処理
    showPopup("profit"); // 利益のポップアップを表示

    // 消費処理
    market.consume(); // 市場の消費処理
    market.updateBrandPoint(); // 市場のブランドポイントを更新
    market.getBrandRanking(); // ブランドの価値ランキングを更新

    // その時の供給在庫を更新
    marketStockKeep = market.marketStock.clone();

    // イベント効果のリセット。永続効果は残る
    resetEventEffect(); 

    // ターン更新
    currentTurn++;
    currentYear_season = getCurrentYear(); // 年と季節の更新

    // 次のターンの開始処理
    startNextTurn();
  }

  // 次のターンの開始処理
  void startNextTurn() {
    // 米を古くする処理
    if ("秋".equals(SEASONS[currentYear_season[SEASON]])) {
      println("米が古くなりました。");
      player.decayRice(); // プレイヤーの米を古くする
      ai.decayRice(); // AIの米を古くする 
    }
    
    showPopup("year"); // 年のポップアップを表示

    // ここでイベントの発生とポップアップ表示を行う

    // ここで通知や予報のポップアップ表示を行う
  }
}
