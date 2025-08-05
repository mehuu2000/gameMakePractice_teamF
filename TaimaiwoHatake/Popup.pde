// 出荷選択や手札戻し、利益描画などのポップアップの描画を管理するクラス
String[] riceOldInfo = {"新米", "古米", "古古米"};
class Popup {

  // ポップアップの種類を定義
  void drawPopup(String type) {
    switch(type) {
    case "year":
      drawYearPopup();
      break;
    case "carry":
      drawCarryPopup();
      break;
    case "cell":
      drawCellPopup();
      break;
    case "buy":
      drawBuyPopup();
      break;
    case "submit":
      drawSubmitPopup();
      break;
    case "return":
      drawReturnPopup();
      break;
    case "turnEnd":
      drawTurnEndPopup();
      break;
    case "countStart":
      drawCountStartPopup();
      break;
    case "fluctuation":
      drawFluctuationPopup();
      break;
    case "profit":
      drawProfitPopup();
      break;
    case "event":
      drawEventPopup();
      break;
    default:
      // 何もしないか、エラーメッセージを表示
      break;
    }

    drawCloseButton();
  }

  // 年数ポップアップの描画
  void drawYearPopup() {
    fill(21, 96, 130);
    rect(width/2 - 250, height/2 - 100, 500, 200);

    fill(0);
    textSize(120);
    text(currentTurn + "年目", width/2, height/2 + 40);
  }

  // 市場に持ち運ばれた米を表示するポップアップの描画
  void drawCarryPopup() {
    stroke(0);
    strokeWeight(2);

    fill(240);
    rect((width * 0.3) + 100, 100, (width * 0.7) - 200, height - 200);

    fill(0);
    textSize(40);
    textAlign(LEFT, CENTER);
    text("市場にお米が", (width * 0.3) + 200, 180);
    text("持ち運ばれました！", (width * 0.3) + 200, 230);
    textAlign(CENTER, CENTER);
  }

  // 米の購入による市場変動のポップアップの描画
  void drawCellPopup() {
    stroke(0);
    strokeWeight(2);

    fill(240);
    rect((width * 0.3) + 100, 100, (width * 0.7) - 200, height - 200);

    fill(0);
    textSize(40);
    textAlign(LEFT, CENTER);
    text("市場からお米が", (width * 0.3) + 200, 180);
    text("購入されました！", (width * 0.3) + 200, 230);
    textAlign(CENTER, CENTER);
  }

  // 買い付けポップアップの描画
  void drawBuyPopup() {
    stroke(0);
    strokeWeight(2);

    fill(240);
    rect((width * 0.3) + 50, 70, (width * 0.7) - 100, height - 175);

    stroke(0);
    line((width * 0.3) + 50, height - 250, width - 52, height - 250);
    noStroke();

    fill(0);
    textSize(40);
    text("どのお米を購入しますか？", (width * 0.3) + 350, 130);

    // ブランド表示
    textAlign(LEFT, CENTER);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      fill(255);
      stroke(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      rect((width * 0.3) + 120, 210 + (i*60), 30, 45); // デモ用のカード
      fill(riceBrandsInfo[riceBrandRanking[i]].brandColor);
      text(riceBrandsInfo[riceBrandRanking[i]].name, (width * 0.3) + 170, 230 + (i*60));
    }
    fill(0);
    noStroke();

    // 価格表示
    textAlign(RIGHT, CENTER);
    for (int i=0; i<riceBrandsInfo.length; i++) {
      text(riceBrandsInfo[riceBrandRanking[i]].point + "pt", (width * 0.3) + 576, 230 + (i*60));
    }

    // 購入数表示
    textAlign(CENTER, CENTER);
    text("購入数", (width * 0.3) + 700, 170);
    for (int i=0; i<riceBrandsInfo.length; i++) {
        brandMinus1Buttons[i].display();
        text(selectedAmounts[riceBrandRanking[i]], (width * 0.3) + 700, 230 + (i*60));
        brandPlus1Buttons[i].display();
    }

    textSize(36);
    textAlign(RIGHT, CENTER);

    text("購入合計金額 ", (width * 0.3) + 350, height - 200);
    text(totalPrice + " pt", (width * 0.3) + 500, height - 200);

    text("購入後残金 ", (width * 0.3) + 350, height - 150);
    text((player.wallet - totalPrice) + " pt", (width * 0.3) + 500, height - 150);

    buyButton.display();

    textAlign(CENTER, CENTER);
  }

  // 提出ポップアップの描画
  void drawSubmitPopup() {
    if (!isFirst) {
        sumBrandCount = player.getSumHandRice(selectedBrandId);
        isFirst = true;
    }

    fill(240);
    stroke(0);
    strokeWeight(2);
    rect((width * 0.3) + 140, 70, (width * 0.7) - 190, height - 90);

    line((width * 0.3) + 140, height - 170, width - 52, height -170);
    noStroke();

    fill(0);
    rect((width * 0.3) + 190, 230, 100, 180); //デモ

    textSize(52);
    text("アットホーム", (width * 0.3) + 460, 330); //デモ

    textSize(40);
    textAlign(LEFT, CENTER);
    text("米の名前", (width * 0.3) + 220, 140);
    text("を何枚提出しますか？", (width * 0.3) + 220, 190);
    textAlign(CENTER, CENTER);

    minus1SelectedButton.display();
    fill(0);
    textSize(36);
    text(selectedAmounts[selectedBrandId], 1120, 312);
    plus1SelectedButton.display();

    fill(0);
    textSize(36);
    text("提出数", (width * 0.3) + 730, 250);
    for (int i=0; i<riceOldInfo.length; i++) {
      text(riceOldInfo[i], (width * 0.3) + 280+(i*150), height - 280);
      text(player.handRices[selectedBrandId][i], (width * 0.3) + 280+(i*150), height - 230);
    }
    text("総数", (width * 0.3) + 280+(3*150), height - 280);
    text(sumBrandCount, (width * 0.3) + 280+(3*150), height - 230);

    closePopupButton.display();
    submitButton.display();
  }

  // 手札に戻すポップアップの描画
  void drawReturnPopup() {
  }

  // ターン終了ポップアップの描画
  void drawTurnEndPopup() {
  }

  // 集計開始ポップアップの描画
  void drawCountStartPopup() {
  }

  //米の出荷による市場変動のポップアップの描画
  void drawFluctuationPopup() {
  }

  // 利益のポップアップのための描画
  void drawProfitPopup() {
  }

  // イベントポップアップの描画
  void drawEventPopup() {
  }

  // ポップアップを閉じるためのボタン描画
  void drawCloseButton() {
  }
}
