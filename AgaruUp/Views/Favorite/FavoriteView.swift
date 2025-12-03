//
//  FavoriteView.swift
//  AgaruUp
//
//

import SwiftUI
import AVKit

// MARK: - Models

struct FavoriteItem: Identifiable {
    // FeedViewのID(String)に合わせてStringに変更しています
    let id: String
    let imageName: String
    let title: String
    let location: String
    let createdDate: String
}

// MARK: - Mock Data

extension FavoriteItem {
    static let mocks: [FavoriteItem] = [
        // FeedViewへ飛ばしたいIDを設定します
        // ※Assetsに "photo01" などの画像がある前提です
        FavoriteItem(id: "video_1", imageName: "photo01", title: "過去一アガった瞬間！！", location: "大阪府大阪市北区梅田hoge", createdDate: "2025/11/19 生成"),
        FavoriteItem(id: "video_2", imageName: "photo02", title: "過去一アガった瞬間！！", location: "大阪府大阪市北区梅田hoge", createdDate: "2025/11/19 生成"),
        FavoriteItem(id: "video_3", imageName: "photo03", title: "過去一アガった瞬間！！", location: "大阪府大阪市北区梅田hoge", createdDate: "2025/11/20 生成")
    ]
}

// MARK: - Views

struct FavoriteView: View {
    @State private var isShowingSearch = false
    
    // プロジェクト内に既にある本物の VideoPlaybackManager を使用します
    @State private var playbackManager = VideoPlaybackManager()
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    private let items = FavoriteItem.mocks

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // MARK: - カスタムヘッダーエリア
                HStack {
                    Text("お気に入り")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        isShowingSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
                .padding(.bottom, 10)
                .background(Color.clear)

                // MARK: - メインコンテンツ
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(items) { item in
                            // タップしたらFeedViewへ遷移
                            NavigationLink {
                                // プロジェクト既存の FeedView を呼び出す
                                FeedView(playbackManager: playbackManager)
                            } label: {
                                FavoriteGridItemView(item: item)
                            }
                            // ボタンの見た目（青文字など）にならないようプレーンスタイルにする
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                }
            }
            // ツールバーを隠してカスタムヘッダーを使う設定
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isShowingSearch) {
                SearchView()
            }
        }
    }
}

/// グリッド内の個別のアイテムビュー
struct FavoriteGridItemView: View {
    let item: FavoriteItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                // 画像を表示（Assetsに画像がない場合はグレー背景になります）
                Image(item.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .aspectRatio(3 / 4, contentMode: .fit)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.callout)
                    .fontWeight(.bold)
                    .lineLimit(1)
                    .foregroundStyle(.primary)
                
                Text(item.location)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(item.createdDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    FavoriteView()
}
