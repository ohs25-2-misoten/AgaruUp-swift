//
//  SearchView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/13.
//

import SwiftUI

struct SearchView: View {
  @State private var searchText: String = ""
  private let tags = ["#Tag1", "#Tag2", "#Tag3", "#Tag4", "#Tag5"]

  var body: some View {
    VStack {
      TextField("Search", text: $searchText)
        .textFieldStyle(.withCancel)
      FlowLayout(alignment: .center, spacing: 10) {
        ForEach(tags, id: \.self) { tag in
          Text(tag)
            .padding(.vertical, 5)
            .padding(.horizontal, 12)
            .background(Color(.systemGroupedBackground))
            .cornerRadius(15)
        }
      }
      Spacer()
      Button {

      } label: {
        Text("検索")
          .font(.headline)
          .padding(.vertical, 12)
          .frame(maxWidth: .infinity)
          .background(Color("background"))
          .foregroundColor(.white)
          .cornerRadius(12)
          .shadow(color: Color("background").opacity(0.4), radius: 5, x: 0, y: 5)
      }
    }
    .padding()
  }
}

#Preview {
  SearchView()
}
