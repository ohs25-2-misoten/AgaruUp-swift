//
//  ProgressIndicator.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct ProgressIndicator: View {
  @State private var progress: Double = 0.0

  private let stepAmount: Double = 0.1
  private let backgroundColor = Color.gray.opacity(0.3)
  private let indicatorColor = Color.orange
  var action: () -> Void = { }

  var body: some View {
    VStack(spacing: 25) {
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 15)
          .fill(backgroundColor)
          .frame(height: 30)

        RoundedRectangle(cornerRadius: 15)
          .fill(indicatorColor)
          .frame(width: max(0, min(CGFloat(progress) * 300, 300)), height: 30)
          .shadow(color: indicatorColor.opacity(0.5), radius: 5, x: 0, y: 3)

        Text("\(Int(progress * 100))%")
          .font(.caption)
          .fontWeight(.semibold)
          .foregroundColor(progress > 0.4 ? .white : .black.opacity(0.7))
          .frame(maxWidth: .infinity, alignment: .center)
      }
      .frame(maxWidth: 300)
      .animation(.easeInOut(duration: 0.5), value: progress)

      Button(action: {
        progress = min(1.0, progress + stepAmount)
      }) {
        Text("アガる")
              .frame(maxWidth: .infinity)
      }
      .frame(maxWidth: 300)
      .buttonStyle(.glassProminent)
      .controlSize(.extraLarge)
    }
    .padding()
  }
}

#Preview {
  ProgressIndicator()
}
