# ブランチ規則 (Branching Rules)

## 概要
このドキュメントは、AgaruUpプロジェクトにおけるトランクベース開発のブランチ管理規則を定義します。
Xcode Cloudとの統合を前提とした、シンプルで効率的なワークフローを採用しています。

## ブランチ戦略

### トランクベース開発 (Trunk-Based Development)
- **メインブランチ**: `main`（常にデプロイ可能な状態を維持）
- **フィーチャーブランチ**: 短命なブランチで機能開発
- **リリース**: バージョンアップ用の専用ブランチ
- **CI/CD**: Xcode Cloudが`main`へのマージで自動ビルド・デプロイ

## ブランチの種類

### 1. メインブランチ (Main Branch)

#### `main`
- **目的**: 本番環境にデプロイ可能な安定したコード
- **特徴**: 
  - すべての開発の中心となるブランチ
  - Xcode Cloudが`main`へのマージを検知して自動ビルド
  - App Store Connectへ自動アップロード
- **マージ条件**: 
  - プルリクエスト必須
  - レビュー承認必須
  - CI/CDチェック通過必須

### 2. サポートブランチ (Supporting Branches)

#### フィーチャーブランチ (`feat/*`, `fix/*`)
- **命名規則**: `feat/[機能名]` または `fix/[修正内容]`
- **例**: 
  - `feat/user-authentication`
  - `feat/123-profile-screen`
  - `fix/video-playback-crash`
- **作成元**: `main`
- **マージ先**: `main`
- **ライフサイクル**: 短期間（数日以内を推奨）
- **削除**: マージ後に削除

#### リリースブランチ (`release/bump-version-*`)
- **命名規則**: `release/bump-version-[バージョン]`
- **例**: `release/bump-version-1.1.0`
- **作成元**: `main`
- **マージ先**: `main`
- **目的**: バージョン番号の更新のみ
- **削除**: マージ後に削除

#### ホットフィックスブランチ (`hotfix/*`)
- **命名規則**: `hotfix/[問題の説明]`
- **例**: `hotfix/critical-crash-fix`
- **作成元**: `main`
- **マージ先**: `main`
- **目的**: 緊急の本番バグ修正
- **削除**: 修正完了後に削除

## ワークフロー

### 1. 通常の開発（新機能・バグ修正）

```bash
# mainブランチから機能ブランチを作成
git checkout main
git pull origin main
git checkout -b feat/new-feature

# 開発作業...
git add .
git commit -m "feat: 新機能の実装"
git push origin feat/new-feature

# PRを作成してレビュー → mainにマージ
# Xcode Cloudが自動でビルド・TestFlightアップロード
```

**ポイント**:
- 開発中はバージョン番号を変更しない
- mainへのマージで自動的にTestFlightにビルドがアップロードされる
- ビルド番号はXcode Cloudが自動管理

### 2. リリース準備（バージョンアップ）

```bash
# mainからリリース用ブランチを作成
git checkout main
git pull origin main
git checkout -b release/bump-version-1.1.0

# バージョン番号のみ更新
xcrun agvtool new-marketing-version 1.1.0

# 変更をコミット
git add AgaruUp.xcodeproj/project.pbxproj
git commit -m "chore: バージョンを1.1.0に更新"
git push origin release/bump-version-1.1.0

# PRを作成してレビュー → mainにマージ
```

### 3. リリース後のタグ付け

```bash
# mainにマージされた後
git checkout main
git pull origin main

# リリースタグを作成
git tag -a v1.1.0 -m "Release version 1.1.0"
git push origin v1.1.0
```

### 4. ホットフィックス（緊急修正）

```bash
# mainからホットフィックスブランチを作成
git checkout main
git pull origin main
git checkout -b hotfix/critical-bug-fix

# 修正作業...
git add .
git commit -m "fix: 緊急バグ修正"
git push origin hotfix/critical-bug-fix

# PRを作成してレビュー → mainにマージ
# 必要に応じてパッチバージョンを上げる（例: 1.1.0 → 1.1.1）
```

## バージョニング戦略

### バージョン番号の管理

#### MARKETING_VERSION（ユーザー向けバージョン）
- **形式**: Semantic Versioning (`MAJOR.MINOR.PATCH`)
- **管理方法**: 手動でリリース時に更新
- **例**: `1.0.0` → `1.1.0` → `2.0.0`

#### CURRENT_PROJECT_VERSION（ビルド番号）
- **形式**: 整数（`1`, `2`, `3`...）
- **管理方法**: Xcode Cloudが自動インクリメント
- **設定**: Xcode Cloud設定で「Automatically manage build numbers」を有効化

### バージョンアップのタイミング

| 変更内容 | バージョンアップ | 例 |
|---------|----------------|-----|
| 破壊的変更・大規模アップデート | MAJOR | `1.5.0` → `2.0.0` |
| 新機能追加 | MINOR | `1.0.0` → `1.1.0` |
| バグ修正のみ | PATCH | `1.0.0` → `1.0.1` |

### バージョン更新コマンド

```bash
# バージョン番号を変更
xcrun agvtool new-marketing-version 1.1.0

# 現在のバージョンを確認
xcrun agvtool what-marketing-version

# ビルド番号を確認（通常は触らない）
xcrun agvtool what-version
```

## CI/CD統合

### Xcode Cloud自動ビルドフロー

1. **開発中のビルド**:
   - フィーチャーブランチ → `main`へマージ
   - Xcode Cloudが自動ビルド
   - TestFlightに内部テスト用としてアップロード
   - バージョン: `1.0.0 (build XX)`

2. **リリースビルド**:
   - `release/bump-version-X.X.X` → `main`へマージ
   - Xcode Cloudが自動ビルド
   - バージョンが更新された状態でApp Store Connectにアップロード
   - バージョン: `1.1.0 (build YY)`

3. **ビルド番号の自動管理**:
   - Xcode Cloudが各ビルドごとに自動でインクリメント
   - 手動での変更は不要

## コミットメッセージ規則

### 形式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### タイプ (Type)
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント変更
- `style`: コードスタイルの変更
- `refactor`: リファクタリング
- `test`: テストの追加・修正
- `chore`: その他の変更

### 例
```
feat(auth): ユーザー認証機能を追加

- ログイン画面の実装
- Firebase Authenticationとの連携
- バイオメトリクス認証のサポート

Closes #123
```

## プルリクエスト規則

### 必須条件
- [ ] 適切なブランチから作成されている
- [ ] コンフリクトが解決されている
- [ ] テストが通っている
- [ ] コードレビューを受けている

### テンプレート
```markdown
## 概要
このプルリクエストの概要を記述

## 変更内容
- 変更点1
- 変更点2

## テスト
- [ ] 既存のテストが通る
- [ ] 新規テストを追加済み
- [ ] 手動テストを実施済み

## チェックリスト
- [ ] コードスタイルガイドに従っている
- [ ] 適切なコメントを追加している
- [ ] ドキュメントを更新している（必要な場合）

## 関連Issue
Closes #[issue番号]
```

## タグ付けルール

### バージョニング
Semantic Versioning (SemVer) を採用

- **MAJOR**: 破壊的変更
- **MINOR**: 後方互換性のある新機能
- **PATCH**: 後方互換性のあるバグ修正

### 例
- `v1.0.0`: 初回リリース
- `v1.1.0`: 新機能追加
- `v1.1.1`: バグ修正

## ブランチ保護設定

### `main`ブランチ
- 直接プッシュ禁止
- プルリクエスト必須
- レビュー承認必須
- ステータスチェック必須

## よくある質問

### Q: 小さな修正でもブランチを作成する必要がありますか？
A: はい。どんな小さな変更でも、トレーサビリティとレビューのためにブランチを作成することを推奨します。

### Q: リリースブランチでの作業内容は？
A: バージョン番号の更新のみ。新機能やバグ修正は含めません。

### Q: ホットフィックスとバグフィックスの違いは？
A: ホットフィックスは本番環境の緊急修正、バグフィックスは通常の開発サイクル内での修正です。

### Q: devブランチはどうなったの？
A: トランクベース開発に移行したため、`dev`ブランチは使用しません。すべての開発は`main`ブランチを基点とします。

### Q: TestFlightに頻繁にビルドがアップロードされるけど大丈夫？
A: はい。Xcode Cloudが自動でビルドしますが、TestFlightでは内部テスト用として扱います。App Storeへの提出は手動で行います。

### Q: ビルド番号はどうやって管理する？
A: Xcode Cloudの「Automatically manage build numbers」機能で自動管理されます。手動での変更は不要です。

---

**最終更新**: 2025年12月11日
**バージョン**: 2.0
