# gameMakePractice_teamF

## プロジェクト概要
このリポジトリはProcessingを使用したゲーム開発の練習プロジェクトです。

## テスト
MagicalBulletHell.pdeを実行してテスト

## 基本的なGit操作コマンド

### 初期設定
```bash
# ユーザー名の設定
git config --global user.name "あなたの名前"

# メールアドレスの設定
git config --global user.email "your.email@example.com"
```

### リポジトリの操作
```bash
# リポジトリのクローン（複製）
git clone https://github.com/mehuu2000/gameMakePractice_teamF.git

# 現在の状態を確認
git status

# 変更履歴を確認
git log
git log --oneline  # 簡潔な表示
```

### 基本的な作業フロー
```bash
# 1. 変更したファイルをステージングエリアに追加
git add ファイル名
git add .  # すべての変更を追加

# 2. コミット（変更を記録）
git commit -m "変更内容の説明"

# 3. リモートリポジトリにプッシュ（送信）
git push origin main
```

### ブランチ操作
```bash
# ブランチの一覧表示
git branch

# 新しいブランチを作成して切り替え
git checkout -b 新しいブランチ名

# 既存のブランチに切り替え
git checkout ブランチ名

# ブランチをマージ
git checkout main  # mainブランチに移動
git merge ブランチ名
```

### 変更の取り消し
```bash
# ステージング前の変更を取り消し
git checkout -- ファイル名

# ステージングを取り消し（変更は保持）
git reset HEAD ファイル名

# 直前のコミットを修正
git commit --amend -m "新しいコミットメッセージ"
```

### リモートリポジトリとの同期
```bash
# リモートの変更を取得
git pull origin main

# リモートの変更を確認（ローカルには反映しない）
git fetch origin
```

### よく使うエイリアス設定
```bash
# エイリアスの設定例
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit

# 使用例
git st  # git status と同じ
```

## 注意事項
- コミットメッセージは変更内容が分かりやすいように書く
- 大きな変更は小さなコミットに分けて行う
- mainブランチに直接pushしないこと。自分が切ったブランチにpushし、developに対してプルリクすること
- `.gitignore`ファイルで不要なファイルを管理対象外にする

## 参考リンク
- [Git公式ドキュメント](https://git-scm.com/doc)
- [GitHub Docs](https://docs.github.com/ja)
