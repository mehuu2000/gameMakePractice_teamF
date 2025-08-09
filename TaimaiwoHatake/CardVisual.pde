// カードの見た目を定義するクラス

class CardVisual {

    /* 以下は実装例 */
    // カードの画像を格納する配列
    PImage[] cardImages;
    boolean imagesLoaded = false; // 画像が読み込まれたかのフラグ
    
    // 画像読み込み（一度だけ実行される）
    void loadCardImages() {
      if (!imagesLoaded) {
        cardImages = new PImage[4];
        cardImages[0] = loadImage("rice_card_ryouomoi.png");
        cardImages[1] = loadImage("rice_card_hoshihikari.png");
        cardImages[2] = loadImage("rice_card_yumegogochi.png");
        cardImages[3] = loadImage("rice_card_tsuyaouji.png");
        imagesLoaded = true;
      }
    }

    // カードの描画
    void drawCard() {
      
    }

    // カードの裏面描画(AIが出したやつ)
    void drawCardBack() {}

    // 複数米時のカードを描画
    void drawMultipleCards() {}

    // 米の古さ描画
    void drawOldRiceCount() {}
}
