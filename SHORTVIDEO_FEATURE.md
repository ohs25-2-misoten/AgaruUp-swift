# ショート動画スクロール機能

## 概要

TikTokやInstagram Reelsのような、縦にスクロールできるショート動画プロトタイプ画面を実装しました。

## 実装内容

### 主要コンポーネント

1. **VideoModel** (`AgaruUp/Models/VideoModel.swift`)
   - 動画データを表現するモデル
   - URL、タイトル、説明を含む
   - サンプル動画データを提供

2. **VideoPlayerView** (`AgaruUp/Views/VideoPlayerView.swift`)
   - AVPlayerを使用した動画再生ビュー
   - 機能：
     - 自動再生
     - ループ再生
     - 動画情報のオーバーレイ表示
     - プログレスインジケーター

3. **ShortVideoScrollView** (`AgaruUp/Views/ShortVideoScrollView.swift`)
   - メインのショート動画スクロールビュー
   - 機能：
     - 縦方向のページングスクロール
     - スナップ動作
     - 動画インデックス表示

## 使い方

### アプリ起動後

1. アプリを起動すると、タブバーが表示されます
2. 「動画」タブを選択すると、ショート動画スクロール画面が表示されます
3. 上下にスワイプして動画を切り替えます
4. 各動画は自動的に再生され、ループします

### カスタマイズ

動画を追加・変更するには、`VideoModel.swift`の`sampleVideos`配列を編集してください：

```swift
extension VideoModel {
    static let sampleVideos: [VideoModel] = [
        VideoModel(
            url: URL(string: "YOUR_VIDEO_URL")!,
            title: "動画タイトル",
            description: "動画の説明"
        ),
        // 他の動画を追加...
    ]
}
```

## 技術仕様

- **フレームワーク**: SwiftUI
- **動画再生**: AVKit (AVPlayer)
- **スクロール実装**: TabView with PageTabViewStyle
- **TCA**: 使用していません（シンプルな実装）

## 対応OS

- iOS 17.0以降

## 注意事項

- ネットワーク経由で動画を読み込むため、インターネット接続が必要です
- `Info.plist`に`NSAppTransportSecurity`設定を追加しています
- 動画ファイルのサイズによっては、初回読み込みに時間がかかる場合があります

## 今後の拡張予定

- [ ] いいねボタン
- [ ] コメント機能
- [ ] シェア機能
- [ ] フォロー機能
- [ ] ユーザープロフィール表示
- [ ] 動画のキャッシング
- [ ] オフライン再生
- [ ] 再生速度の調整
