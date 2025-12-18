//
//  Notification.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/12/18.
//

import SwiftUI

struct NotificationView: View {
    let message: String

    var body: some View {
        Text(message)
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .padding(.top, 50)
    }
}
