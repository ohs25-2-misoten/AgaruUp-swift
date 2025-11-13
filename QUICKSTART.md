# ショート動画プロトタイプ - クイックスタート

## 📱 実装内容

TikTok/Instagram Reelsのような、縦にスナップしながらスクロールできるショート動画プロトタイプを作成しました。

## ✨ 主な機能

- 🎬 **縦スクロール**: 上下スワイプで動画を切り替え
- 🔄 **自動ループ再生**: 動画が終わったら最初から再生
- 📍 **スナップ動作**: 動画ごとにピタッと止まる
- 📊 **インデックス表示**: 現在の動画位置（1/5など）
- 🎨 **オーバーレイUI**: タイトルと説明を動画上に表示
- 📱 **タブ切り替え**: 動画タブとリストタブを切り替え可能

## 🏗️ ファイル構成

```
AgaruUp/
├── Models/
│   └── VideoModel.swift           ← 動画データモデル (NEW)
├── Views/
│   ├── VideoPlayerView.swift      ← 動画プレーヤー (NEW)
│   └── ShortVideoScrollView.swift ← メイン画面 (NEW)
└── ContentView.swift               ← タブビューに更新 (UPDATED)

Info.plist                          ← ネットワーク許可追加 (UPDATED)

ドキュメント:
├── SHORTVIDEO_FEATURE.md          ← 機能説明
└── ARCHITECTURE.md                 ← アーキテクチャ図
```

## 🚀 使い方

### アプリ起動

1. Xcodeでプロジェクトを開く
   ```bash
   open AgaruUp.xcodeproj
   ```

2. ビルドして実行 (⌘R)

3. アプリが起動すると、下部に2つのタブが表示されます：
   - **動画タブ** (play.rectangle.fill): ショート動画画面
   - **リストタブ** (list.bullet): 既存のアイテムリスト

### 操作方法

- **上スワイプ**: 次の動画へ
- **下スワイプ**: 前の動画へ
- 動画は自動的に再生され、ループします

## 🎥 サンプル動画

Google Cloud Storageのサンプル動画を5つ使用：
1. Big Buck Bunny
2. Elephants Dream
3. For Bigger Blazes
4. For Bigger Escapes
5. For Bigger Fun

### 動画の追加/変更

`AgaruUp/Models/VideoModel.swift` の `sampleVideos` 配列を編集：

```swift
extension VideoModel {
    static let sampleVideos: [VideoModel] = [
        VideoModel(
            url: URL(string: "動画のURL")!,
            title: "タイトル",
            description: "説明"
        ),
        // 他の動画...
    ]
}
```

## 🛠️ 技術スタック

- **SwiftUI**: ユーザーインターフェース
- **AVKit**: 動画再生 (AVPlayer)
- **TabView**: ページングスクロール
- **TCA**: 使用していません（シンプル実装）

## 📝 コード統計

- **新規作成**: 3ファイル (196行)
- **更新**: 2ファイル (72行)
- **ドキュメント**: 2ファイル
- **合計**: 268行のSwiftコード

## 🔧 設定

### Info.plist

ネットワーク動画を再生するため、以下の設定を追加済み：

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 📱 動作環境

- iOS 17.0以降
- Xcode 16.0以降
- インターネット接続（動画読み込み用）

## 🎯 今後の拡張案

- [ ] いいねボタン
- [ ] コメント機能
- [ ] シェア機能
- [ ] ユーザープロフィール
- [ ] 動画アップロード
- [ ] キャッシング機能
- [ ] オフライン再生

## 📚 詳細ドキュメント

- [SHORTVIDEO_FEATURE.md](./SHORTVIDEO_FEATURE.md) - 機能の詳細説明
- [ARCHITECTURE.md](./ARCHITECTURE.md) - アーキテクチャ図とデータフロー
