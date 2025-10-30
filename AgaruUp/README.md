# AgaruUp

AgaruUpは、SwiftUIとSwiftDataを使用して開発されたiOSアプリケーションです。

## 📱 概要

このプロジェクトは、[プロジェクトの目的や機能を簡潔に説明]を目的として開発されています。

## 🛠️ 技術スタック

- **言語**: Swift 6.0+
- **フレームワーク**: SwiftUI
- **データ管理**: SwiftData
- **開発環境**: Xcode 16.0+
- **対象OS**: iOS 17.0+

## 🚀 セットアップ

### 必要条件

- macOS 14.0 (Sonoma) 以降
- Xcode 16.0 以降
- iOS 17.0 以降のデバイスまたはシミュレータ

### インストール手順

1. リポジトリをクローンします：
```bash
git clone [リポジトリURL]
cd AgaruUp
```

2. Xcodeでプロジェクトを開きます：
```bash
open AgaruUp.xcodeproj
```

3. 必要に応じて署名とチーム設定を行います：
   - プロジェクト設定 > Signing & Capabilities
   - 開発者アカウントを選択

4. ビルドして実行します：
   - `Cmd + R` または Run ボタンをクリック

## 📁 プロジェクト構造

```
AgaruUp/
├── AgaruUpApp.swift          # アプリのエントリーポイント
├── Views/                    # SwiftUIビュー
│   └── ContentView.swift
├── Models/                   # データモデル
│   └── Item.swift           # SwiftDataモデル
├── ViewModels/              # ビューモデル
├── Services/                # ビジネスロジック・API
├── Utils/                   # ユーティリティ
├── Resources/               # アセット・リソース
└── Tests/                   # テスト
    ├── AgaruUpTests/        # ユニットテスト
    └── AgaruUpUITests/      # UIテスト
```

## 🔄 開発ワークフロー

このプロジェクトでは、GitFlowベースのブランチ戦略を採用しています。

### ブランチ規則

- `main`: 本番環境用の安定したコード
- `dev`: 開発の中心となるブランチ
- `feat/*`: 新機能開発用ブランチ
- `release/*`: リリース準備用ブランチ
- `hotfix/*`: 緊急修正用ブランチ

詳細は [BRANCHING_RULES.md](./BRANCHING_RULES.md) を参照してください。

### 新機能開発の流れ

1. devブランチから機能ブランチを作成：
```bash
git checkout dev
git pull origin dev
git checkout -b feat/your-feature-name
```

2. 開発・コミット：
```bash
git add .
git commit -m "feat: 新機能の説明"
```

3. プルリクエストを作成してdevにマージ

## 🧪 テスト

### テスト実行

```bash
# Xcode内でテスト実行
Cmd + U

# コマンドラインからテスト実行
xcodebuild test -scheme AgaruUp -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'
```

### テスト構成

- **ユニットテスト**: ビジネスロジックとデータモデルのテスト
- **UIテスト**: ユーザーインターフェースのE2Eテスト
- **パフォーマンステスト**: アプリのパフォーマンス測定

### テスト作成ガイドライン

Swift Testingフレームワークを使用してテストを作成します：

```swift
import Testing
@testable import AgaruUp

@Suite("機能名のテスト")
struct FeatureTests {
    @Test("具体的なテストケース")
    func testSpecificCase() async throws {
        // テスト実装
        #expect(actual == expected)
    }
}
```

## 📝 コーディング規約

### コミットメッセージ

Conventional Commits形式を採用：

```
<type>(<scope>): <subject>

<body>

<footer>
```

**タイプ**:
- `feat`: 新機能
- `fix`: バグ修正
- `docs`: ドキュメント
- `style`: スタイル変更
- `refactor`: リファクタリング
- `test`: テスト
- `chore`: その他

### Swiftコーディングスタイル

- Swift API Design Guidelinesに準拠
- SwiftLintを使用したコード品質管理
- SwiftFormatを使用した自動フォーマット

## 🚢 リリース

### バージョニング

Semantic Versioning (SemVer) を採用：
- `MAJOR.MINOR.PATCH` (例: 1.0.0)

### リリースプロセス

1. devからreleaseブランチを作成
2. バージョン更新とリリース準備
3. mainにマージしてタグ付け
4. App Store Connectにアップロード

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feat/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: 素晴らしい機能を追加'`)
4. ブランチにプッシュ (`git push origin feat/amazing-feature`)
5. プルリクエストを作成

### プルリクエストガイドライン

- [ ] 適切なブランチから作成
- [ ] テストの追加・更新
- [ ] コードレビューの実施
- [ ] コンフリクトの解決
- [ ] ドキュメントの更新（必要な場合）

## 📄 ライセンス

[ライセンス情報を記載]

## 👥 メンテナー

- [alpha9n](mailto:contact@kosuke.dev)

## 📞 サポート

質問や問題がある場合は、以下の方法でお問い合わせください：

- [Issues](../../issues) - バグ報告や機能要望
- [Discussions](../../discussions) - 質問や議論

## 📚 追加リソース

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

---

**最終更新**: 2025年10月30日
