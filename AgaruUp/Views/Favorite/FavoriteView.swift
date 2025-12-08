//
//  FavoriteView.swift
//  AgaruUp
//
//

import SwiftUI
import AVKit

struct FavoriteView: View {
    @State private var isShowingSearch = false
    @State private var playbackManager = VideoPlaybackManager()
    
    private let columns = [
        GridItem(.flexible(), spacing: 15),
        GridItem(.flexible(), spacing: 15)
    ]
    
    // 別ファイル(FavoriteItem.swift)にある定義を使用
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
                            // 別ファイル(FavoriteGridItemView.swift)にあるコンポーネントを使用
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
