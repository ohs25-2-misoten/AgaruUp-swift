//
//  AgaruUpApp.swift
//  AgaruUp
//
//  Created by 神保恒介 on 2025/10/30.
//

import SwiftData
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // アプリ起動時にNotificationManagerの初期化（Delegate設定）を確実に行う
        _ = NotificationManager.shared
        return true
    }
}

@main
struct AgaruUpApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            FavoriteVideo.self,
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
            // Permission requests deferred to specific user actions
            // .task removed
        }
        .modelContainer(sharedModelContainer)
        .environment(NotificationManager.shared)
    }
}
