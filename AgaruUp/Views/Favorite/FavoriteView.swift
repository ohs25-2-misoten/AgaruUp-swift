//
//  FavoriteView.swift
//  AgaruUp
//
//

import SwiftUI
import AVKit

// MARK: - Models

struct FavoriteItem: Identifiable {
    let id: String
    let imageName: String
    let title: String
    let location: String
    let createdDate: String
}

// MARK: - Mock Data

extension FavoriteItem {
    static let mocks: [FavoriteItem] = [
        FavoriteItem(id: "video_1", imageName: "photo01", title: "過去一アガった瞬間！！", location: "大阪府大阪市北区梅田hoge", createdDate: "2025/11/19 生成"),
        FavoriteItem(id: "video_2", imageName: "photo02", title: "過去一アガった瞬間！！", location: "大阪府大阪市北区梅田hoge", createdDate: "2025/11/19 生成"),
        FavoriteItem(id: "video_3", imageName: "photo03", title: "最高のデザート", location: "東京都渋谷区", createdDate: "2025/11/20 生成")
    ]
}

// MARK: - Views

struct FavoriteView: View {
    @State private var isShowingSearch = false
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
                            // 別ファイルに切り出した View を使用
                            NavigationLink {
                                FeedView(playbackManager: playbackManager)
                            } label: {
                                FavoriteGridItemView(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 80)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $isShowingSearch) {
                SearchView()
            }
        }
    }
}

#Preview {
    FavoriteView()
}
