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
                    FlowLayout(alignment: .center, spacing: 10) {
                        ForEach(filteredTags, id: \.self) { tag in
                            Text("#\(tag)")
                                .padding(.vertical, 5)
                                .padding(.horizontal, 12)
                                .background(Color(.systemGroupedBackground))
                                .cornerRadius(15)
                        }
                    }
                }

                Spacer()
                
                if !searchText.isEmpty {
                    Button(action: handleSearch) {
                        Text("「\(searchText)」で検索")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.glassProminent)
                    .controlSize(.extraLarge)
                }
            }
            .padding()
            .navigationTitle("検索")
        }
        .searchable(text: $searchText, prompt: "動画を検索")
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
        // TODO: 検索と統合
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

#Preview {
    SearchView()
}
