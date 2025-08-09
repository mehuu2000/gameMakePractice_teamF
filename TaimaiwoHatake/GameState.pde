// ゲーム状態管理クラス

// TEST：テスト状態
// START：ゲーム開始前の状態
// PLAYING：ゲームプレイ中の状態
// FINISHED：ゲーム終了状態
enum State {
  TITLE,
  DESCRIBE,
  DESCRIBE2,
  DESCRIBE3,
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

  // 米購入関数 
  void forBuyRice() {
    println("forBuyRice開始");
    if (player.wallet - totalPrice < 0) {
      println("forBuyRice: 残金不足");
      return; // 残金が足りない場合は何もしない
    }
    for (int i = 0; i < riceBrandsInfo.length; i++){
      if (selectedAmounts[i] > 0) {
        println("ブランド" + i + "を" + selectedAmounts[i] + "枚購入");
        player.buyRice(i, selectedAmounts[i]);
      }
    }
    // confirmBuyAndShip()から呼ばれた場合は既に閉じているので、ここでは閉じない
    if (!isFromBuyScreen) {
      closePopup();
    }
  }
  
  // 購入してから出荷する関数（確認画面を表示）
  void buyAndShip() {
    if (player.wallet - totalPrice < 0) {
      return; // 残金が足りない場合は何もしない
    }
    
    // 選択した購入数とtotalPriceを一時的に保存
    println("buyAndShip: 購入数を保存");
    for (int i = 0; i < riceBrandsInfo.length; i++){
      tempSelectedAmounts[i] = selectedAmounts[i]; // 一時保存配列にコピー
      if (selectedAmounts[i] > 0) {
        println("ブランド" + i + ": " + selectedAmounts[i] + "枚");
      }
    }
    tempTotalPrice = totalPrice; // 合計金額も保存
    println("合計金額: " + totalPrice);
    
    // フラグを設定して確認画面を表示（closePopupの前に設定）
    isFromBuyScreen = true;
    
    // 購入ポップアップを閉じる
    closePopup();
    
    // 確認画面を表示
    showPopup("turnEnd");
  }
  
  // 購入を確定してターンを終了する
  void confirmBuyAndShip() {
    println("confirmBuyAndShip開始");
    println("isFromBuyScreen: " + isFromBuyScreen);
    
    // 確認画面を閉じる
    closePopup();
    
    // 購入処理を実行
    println("購入処理前の所持金: " + player.wallet);
    
    // 各ブランドの購入処理
    for (int i = 0; i < riceBrandsInfo.length; i++){
      if (tempSelectedAmounts[i] > 0) {
        println("ブランド" + i + "を" + tempSelectedAmounts[i] + "枚購入");
        player.buyRice(i, tempSelectedAmounts[i]);
      }
    }
    
    println("購入処理後の所持金: " + player.wallet);
    
    // 出荷前の市場在庫を保存（fluctuationポップアップで使用）
    marketStockKeep = market.marketStock.clone();
    
    player.shipRice();
    
    // 一時保存をクリア
    for (int i = 0; i < tempSelectedAmounts.length; i++) {
      tempSelectedAmounts[i] = 0;
    }
    tempTotalPrice = 0;
    
    endTurn(); // 出荷後にターンを進める
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

  // 出荷関数 ボタンでつかうよ（確認画面を表示）
  void playerShipRIce() {
    // フラグを設定して確認画面を表示
    isFromBuyScreen = false;
    showPopup("turnEnd");
  }
  
  // 出荷を確定してターンを終了する
  void confirmShipOnly() {
    // 出荷前の市場在庫を保存（fluctuationポップアップで使用）
    marketStockKeep = market.marketStock.clone();
    
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
    showPopup("return");
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
    if (currentTurn > maxTurn) {
      // ゲーム終了処理、結果画面の表示など
      // もしくは次ターン米騒動?
    }
    
    // 注：marketStockKeepはplayerShipRIce()で既に保存済み
    
    // AIの処理
    ai.aiAction(); // 購入と出荷準備のみ
    ai.shipRice(); // AIの出荷処理

    // ブローカーの出荷状態を保存 (プレイヤーの利益表示ポップアップで使用)
    for (int i=0; i<riceBrandsInfo.length; i++) {
      playerLoadedRices[i] = player.getSumLoadRice(i); // プレイヤーの出荷状態を保存
      aiLoadedRices[i] = ai.getSumLoadRice(i); // AIの出荷状態を保存
    }

    // 出荷直後（消費前）の市場在庫を保存
    marketStockAfterShip = market.marketStock.clone();
    
    market.updateBrandPoint(); // 市場のブランドポイントを更新
    for (int i=0; i<riceBrandsInfo.length; i++) {
      riceBrandKeepPrice[i] = riceBrandsInfo[i].point; // ブランドの価値を保存
    }
    riceBrandRanking = market.getBrandRanking(); // ブランドの価値ランキングを更新

    // 利益処理 (プレイヤーの利益表示ポップアップでも使用される)
    playerProfit = player.sellRice(); // プレイヤーの利益計算
    aiProfit = ai.sellRice(); // AIの利益計算

    // 利益表示処理
    showPopup("countStart"); // 集計開始のポップアップを表示
    showPopup("fluctuation"); // 市場変動のポップアップを表示
    showPopup("profit"); // 利益のポップアップを表示

    // 消費処理
    market.consume(); // 市場の消費処理
    showPopup("cell"); // 消費のポップアップを表示
    market.updateBrandPoint(); // 市場のブランドポイントを更新
    riceBrandRanking = market.getBrandRanking(); // ブランドの価値ランキングを更新

    // イベント効果のリセット。永続効果は残る
    resetEventEffect(); 

    // 次のターンの開始処理はポップアップ終了後に呼ばれる
    // ターン更新もfinishEndTurn()で行う
    // startNextTurn();
  }
  
  // ターン終了の最終処理（全ポップアップ終了後に呼ばれる）
  void finishEndTurn() {
    // その時の供給在庫を更新
    // marketStockKeep = market.marketStock.clone();
    
    // ターン更新（ここでのみ行う）
    currentTurn++;
    currentYear_season = getCurrentYear(); // 年と季節の更新
    
    if (currentTurn > maxTurn) {
      gameState.changeState(State.FINISHED); // 状態をFINISHEDに変更
      return; // 以降の処理は行わない
    }
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
    
    // ポップアップをキューに追加
    showPopup("year"); // 年のポップアップを表示
    if (currentTurn == 1) {
      showPopup("carry"); // 1ターン目は市場への持ち運びも表示
    }
    
    // イベント処理（eventManagerが初期化されている場合のみ）
    if (eventManager != null) {
      eventManager.processCurrentTurn();
      
      // 予報確認（複数の予報がある場合も対応）
      ArrayList<ForecastInfo> allForecasts = eventManager.getAllCurrentForecasts();
      if (allForecasts != null && allForecasts.size() > 0) {
        // 各予報を個別のポップアップとして追加
        for (int i = 0; i < allForecasts.size(); i++) {
          showPopup("news"); // 予報をキューに追加
        }
      }
      
      // イベント確認
      Event currentEvent = eventManager.getCurrentEvent();
      if (currentEvent != null && !currentEvent.eventName.equals("通常")) {
        showPopup("event"); // イベントをキューに追加
      }
      
      // ダミーイベント（外れメッセージ）確認
      Event dummyEvent = eventManager.getCurrentDummyEvent();
      if (dummyEvent != null) {
        showPopup("missed"); // 外れメッセージをキューに追加
      }
    }
  }
}
