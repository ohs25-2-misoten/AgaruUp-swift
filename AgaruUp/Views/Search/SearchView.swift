//
//  SearchView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/13.
//

import SwiftUI

struct SearchView: View {
    @State private var searchText: String = ""
    @State private var tags: [String] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    /// 検索結果への遷移用
    @State private var searchNavigation: SearchNavigation?
    
    @Bindable var playbackManager: VideoPlaybackManager
    
    private let tagService = TagService.shared

    var body: some View {
        NavigationStack {
            VStack {
                if isLoading, tags.isEmpty {
                    ProgressView("タグを読み込み中...")
                        .padding()
                } else if let errorMessage, tags.isEmpty {
                    VStack {
                        Text("エラー")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Button("再試行") {
                            Task {
                                await loadTags()
                            }
                        }
                        .padding()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            if !tags.isEmpty {
                                Text("人気のタグ")
                                    .font(.headline)
                                    .padding(.horizontal)
                                
                                FlowLayout(alignment: .leading, spacing: 10) {
                                    ForEach(filteredTags, id: \.self) { tag in
                                        TagButton(tag: tag) {
                                            searchNavigation = .tag(tag)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("検索")
            .navigationDestination(item: $searchNavigation) { navigation in
                switch navigation {
                case .query(let query):
                    SearchResultsView(
                        query: query,
                        tag: nil,
                        playbackManager: playbackManager
                    )
                case .tag(let tag):
                    SearchResultsView(
                        query: nil,
                        tag: tag,
                        playbackManager: playbackManager
                    )
                }
            }
        }
        .searchable(text: $searchText, prompt: "動画を検索")
        .onSubmit(of: .search) {
            handleSearch()
        }
        .task {
            await loadTags()
        }
    }
    
    /// 検索テキストでフィルタリングしたタグ
    private var filteredTags: [String] {
        if searchText.isEmpty {
            return tags
        }
        return tags.filter { $0.localizedCaseInsensitiveContains(searchText) }
    }

    private func handleSearch() {
        guard !searchText.isEmpty else { return }
        searchNavigation = .query(searchText)
    }

    private func loadTags() async {
        isLoading = true
        errorMessage = nil

        do {
            tags = try await tagService.getTags()
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

// MARK: - SearchNavigation

/// 検索ナビゲーションの種類
enum SearchNavigation: Hashable, Identifiable {
    case query(String)
    case tag(String)
    
    var id: String {
        switch self {
        case .query(let q): return "query:\(q)"
        case .tag(let t): return "tag:\(t)"
        }
    }
}

// MARK: - TagButton

/// タグボタン
struct TagButton: View {
    let tag: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("#\(tag)")
                .font(.subheadline)
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(18)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SearchView(playbackManager: VideoPlaybackManager())
}
