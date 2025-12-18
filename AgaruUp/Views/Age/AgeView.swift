//
//  AgeView.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/11/12.
//

import SwiftUI

struct AgeView: View {
    @State private var isShowingSearch = false
    private let notificationSendModel = NotificationSendModel()

    var body: some View {
        NavigationStack {
            VStack {
                ProgressIndicator {
                    notificationSendModel.sendCompletedNotification()
                }
            }
            .sheet(isPresented: $isShowingSearch) {
                SearchView()
            }
        }
    }
}
