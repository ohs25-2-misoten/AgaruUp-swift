# セットアップガイド

このドキュメントでは、AgaruUpプロジェクトのセットアップ手順について説明します。

## 📋 必要条件

- Xcode 26.0 以降
- iOS 26.0 以降のデバイスまたはエミュレータ

## 📥 インストール手順

1. リポジトリをクローンします：
```bash
git clone https://github.com/ohs25-2-misoten/AgaruUp-swift.git
cd AgaruUp
```

2. Xcodeでプロジェクトを開きます：
```bash
open AgaruUp.xcodeproj
```

3. 必要に応じて署名とチーム設定を行います(エミュレータ開発の場合任意)：
   - プロジェクト設定 > Signing & Capabilities
   - 開発者アカウントを選択

4. ビルドして実行します：
   - `Cmd + R` または Run ボタンをクリック

## 🔌 バックエンドAPI設定

アプリケーションはビルド設定（Configuration）に基づいて、接続するバックエンドAPIを自動的に選択します。

### 環境の種類

| 環境 | スキーム | 用途 | API URL |
|-----|---------|------|---------|
| Debug | AgaruUp | 開発・デバッグ用 | Postman Mockサーバー（プロジェクト設定済み） |
| Staging | AgaruUp - Staging | ステージング環境テスト用 | `https://api.easy-hacking.com` |
| Release | AgaruUp - Release | 本番リリース用 | `https://api.easy-hacking.com` |

> **Note**: Staging環境とRelease環境は同じAPIサーバーを使用しています。これらの環境の違いは、ビルド設定や署名設定など、他のプロジェクト設定によって区別されます。

### 環境の切り替え方法

Xcodeのスキームを選択することで、接続先のバックエンドAPIを切り替えることができます：

1. Xcodeのツールバーでスキームセレクタをクリック
2. 使用したい環境に対応するスキームを選択：
   - **AgaruUp**: Debug環境（モックサーバーを使用した開発向け）
   - **AgaruUp - Staging**: Staging環境（実際のAPIでのテスト向け）
   - **AgaruUp - Release**: Release環境（本番リリース用）
3. ビルドして実行（`Cmd + R`）

### 設定の仕組み

- `Info.plist` の `APIConfiguration` がビルド設定（`$(CONFIGURATION)`）を参照
- `Environment.swift` で各環境のベースURLを定義
- `Configuration.swift` で環境設定を読み込み
- `APIClient.swift` が適切なベースURLを使用してAPIリクエストを送信

## 🔧 トラブルシューティング

### よくある問題

#### ビルドエラーが発生する場合

1. Xcodeを最新版に更新してください
2. `Product > Clean Build Folder` (`Cmd + Shift + K`) を実行
3. `DerivedData` フォルダを削除して再ビルド

#### 署名エラーが発生する場合

1. Xcode > Settings > Accounts で開発者アカウントを確認
2. Target > Signing & Capabilities でチームを正しく選択

#### バックエンドとの接続ができない場合

1. バックエンドサーバーの起動確認
2. バックエンドが下記のAPIを正しく実装している  
   [API docs](https://documenter.getpostman.com/view/28549790/2sB3dHXZ9y#0a2d76d1-5fa0-45d4-85db-1a2511a8d1df:~:text=%E3%82%AB%E3%83%A1%E3%83%A9%E6%83%85%E5%A0%B1%E5%8F%96%E5%BE%97,-https)
3. ビルドスキームが意図したバックエンドを参照しているかを確認する

---

詳細については [README.md](./README.md) を参照してください。
