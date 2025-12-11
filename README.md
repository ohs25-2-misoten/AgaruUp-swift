# AgaruUp

AgaruUpは、SwiftUIとSwiftDataを使用して開発されたiOSアプリケーションです。

## 📱 概要

AgaruUpは、ユーザーが日常生活の中で遭遇した『アガる』出来事をニュース化して共有できるプラットフォームです。
ユーザーは、アガるボタンを押すだけで、その瞬間を生成されるショートニュースを通じて他のユーザーと共有することができます。

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
git clone https://github.com/ohs25-2-misoten/AgaruUp-swift.git
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

このプロジェクトでは、トランクベース開発とXcode Cloud CI/CDを採用しています。

### ブランチ規則

- `main`: 本番環境用の安定したコード（すべての開発の中心）
- `feat/*`: 新機能開発用ブランチ（短命）
- `fix/*`: バグ修正用ブランチ
- `release/bump-version-*`: バージョンアップ用ブランチ
- `hotfix/*`: 緊急修正用ブランチ

詳細は [BRANCHING_RULES.md](./AgaruUp/BRANCHING_RULES.md) を参照してください。

### 新機能開発の流れ

1. mainブランチから機能ブランチを作成：
```bash
git checkout main
git pull origin main
git checkout -b feat/your-feature-name
```

2. 開発・コミット：
```bash
git add .
git commit -m "feat: 新機能の説明"
git push origin feat/your-feature-name
```

3. プルリクエストを作成してmainにマージ
   - Xcode Cloudが自動ビルド
   - TestFlightに内部テスト用としてアップロード

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
- **MARKETING_VERSION**: ユーザー向けバージョン（手動管理）
- **CURRENT_PROJECT_VERSION**: ビルド番号（Xcode Cloud自動管理）

### 自動リリースプロセス

#### 1. バージョンアップPRの作成

```bash
# mainからリリース用ブランチを作成
git checkout main
git pull origin main
git checkout -b release/bump-version-1.1.0

# バージョン番号を更新（GUIまたはCLI）
# 方法1: Xcode GUI
open AgaruUp.xcodeproj
# Target > General > Identity > Version を変更

# 方法2: コマンドライン
xcrun agvtool new-marketing-version 1.1.0

# コミット&プッシュ
git add AgaruUp.xcodeproj/project.pbxproj
git commit -m "chore: バージョンを1.1.0に更新"
git push origin release/bump-version-1.1.0
```

#### 2. PRを作成してマージ

- GitHub上でPRを作成
- GitHub Actionsが自動で `version: 1.1.0` と `release` ラベルを付与
- レビュー承認後、mainにマージ

#### 3. 自動リリース実行

mainへのマージ後、以下が自動実行されます：

1. **Git Tag作成**: `v1.1.0` タグが自動作成
2. **GitHub Release作成**: リリースノート付きで自動作成
3. **Xcode Cloud**: 自動ビルド → App Store Connectにアップロード

### バージョンアップのタイミング

| 変更内容 | バージョン | 例 |
|---------|-----------|-----|
| 破壊的変更・大規模アップデート | MAJOR | `1.5.0` → `2.0.0` |
| 新機能追加 | MINOR | `1.0.0` → `1.1.0` |
| バグ修正のみ | PATCH | `1.0.0` → `1.0.1` |

## 🤝 コントリビューション

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feat/amazing-feature`)
3. 変更をコミット (`git commit -m 'feat: 素晴らしい機能を追加'`)
4. ブランチにプッシュ (`git push origin feat/amazing-feature`)
5. プルリクエストを作成

### プルリクエストガイドライン

- [ ] 適切なブランチ（`main`）から作成
- [ ] テストの追加・更新
- [ ] コードレビューの実施
- [ ] コンフリクトの解決
- [ ] ドキュメントの更新（必要な場合）

### リリースPRの場合

- [ ] ブランチ名が `release/bump-version-X.X.X` 形式
- [ ] `project.pbxproj` のバージョンが更新されている
- [ ] GitHub Actionsによるラベル付けを確認
- [ ] マージ後の自動リリースを確認

## 📄 ライセンス

GNU Affero General Public License v3.0 (AGPL-3.0) ライセンスの下で提供されています。詳細は [LICENSE](./LICENSE) ファイルを参照してください。

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

**最終更新**: 2025年12月11日
