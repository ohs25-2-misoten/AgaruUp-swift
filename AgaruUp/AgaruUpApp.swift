//
//  AgaruUpApp.swift
//  AgaruUp
//
//  Created by 神保恒介 on 2025/10/30.
//

import SwiftData
import SwiftUI

@main
struct AgaruUpApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            FavoriteVideo.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            // FavoriteServiceにModelContainerを設定
            Task { @MainActor in
                FavoriteService.shared.configure(with: container)
            }
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // 初回起動時に通知許可をリクエスト
                    _ = await NotificationManager.shared.requestAuthorization()
                    
                    // BLEスキャンを初期化（Bluetoothの許可ダイアログが表示される）
                    BLECentralManager.shared.initialize()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
