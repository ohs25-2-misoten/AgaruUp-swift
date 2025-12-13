//
//  SearchTextFieldStyle.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/13.
//

import SwiftUI

struct SearchTextFieldStyle: TextFieldStyle {
    @FocusState private var isFocused

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")

                configuration
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(.secondary.opacity(0.3), in: Capsule())

            Button {
                isFocused = false
            } label: {
                Text("Cancel")
            }
            .foregroundStyle(.primary)
        }
    }
}

extension TextFieldStyle where Self == SearchTextFieldStyle {
    static var withCancel: SearchTextFieldStyle {
        .init()
    }
}
