//
//  ProgressIndicator.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct ProgressIndicator: View {
    @State private var progress: Double = 0.0
    @State private var hasCompleted = false

    private let stepAmount: Double = 0.1
    private let backgroundColor = Color.gray.opacity(0.3)
    private let indicatorColor = Color.orange

    let onCompleted: () -> Void

    var body: some View {
        VStack(spacing: 25) {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(backgroundColor)
                    .frame(height: 30)

                RoundedRectangle(cornerRadius: 15)
                    .fill(indicatorColor)
                    .frame(
                        width: max(0, min(CGFloat(progress) * 300, 300)),
                        height: 30
                    )

                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(progress > 0.4 ? .white : .black.opacity(0.7))
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: 300)
            .animation(.easeInOut(duration: 0.5), value: progress)

            Button("アガる") {
                progress = min(1.0, progress + stepAmount)

                if progress >= 1.0 && !hasCompleted {
                    hasCompleted = true
                    onCompleted()
                }
            }
            .frame(maxWidth: 300)
            .buttonStyle(.glassProminent)
            .controlSize(.extraLarge)
        }
        .padding()
    }
}
