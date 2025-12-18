//
//  ContentView.swift
//  AgaruUp
//
//  Created by 神保恒介 on 2025/10/30.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var isLoggedIn: Bool = false
    @State private var hasShownNotificationPermission: Bool = false

    @StateObject private var notificationModel = InAppNotificationModel()
    @State private var playbackManager = VideoPlaybackManager()

    private let permissionModel = NotificationPermissionModel()

    private let dummyVideoURL = URL(
        string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/WeAreGoingOnBullrun.mp4"
    )!

    var body: some View {
        ZStack(alignment: .top) {
            if isLoggedIn {
                MainTabView()
                    .onAppear {
                        if let dummyURL = playbackManager.getLocalVideoURL(
                            fileName: "sample",
                            fileExtension: "mp4"
                        ) {
                            playbackManager.warmupPlayer(with: dummyURL)
                        } else {
                            playbackManager.warmupPlayer(with: dummyVideoURL)
                        }

                        if !hasShownNotificationPermission {
                            hasShownNotificationPermission = true
                            permissionModel.requestPermissionIfNeeded()
                        }
                    }
            } else {
                TopView(isLoggedIn: $isLoggedIn)
            }

            if notificationModel.isVisible {
                NotificationView(message: notificationModel.message)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut, value: notificationModel.isVisible)
                    .padding(.horizontal)
            }
        }
        .environmentObject(notificationModel)
    }
}

#Preview {
    ContentView()
}
