//
//  NotificationManager.swift
//  AgaruUp
//
//  Created on 2026/01/09.
//

import Foundation
import UIKit
import UserNotifications

/// ローカル通知を管理するマネージャー
@Observable
final class NotificationManager: NSObject {
    static let shared = NotificationManager()

    /// 通知が許可されているかどうか
    var isAuthorized: Bool = false

    /// 通知からの遷移先タブを保持する
    var pendingTabSelection: MainTabView.MainTab?

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorizationStatus()
    }
    
    /// 通知権限の状態を確認
    func checkAuthorizationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }

    /// 通知権限をリクエスト
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                isAuthorized = granted
            }
            return granted
        } catch {
            print("[Notification] Authorization request failed: \(error)")
            return false
        }
    }

    /// デバイス発見時の通知を送信（バックグラウンド時のみ）
    func sendDeviceFoundNotification(deviceName: String) {
        // バックグラウンド時のみ通知を送信
        guard UIApplication.shared.applicationState != .active else {
            print("[Notification] App is active, skipping notification")
            return
        }

        guard isAuthorized else {
            print("[Notification] Not authorized, skipping notification")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "カメラを発見！📸"
        content.body = "\(deviceName) が近くにあります。アゲ報告の準備ができました！"
        content.sound = .default
        content.interruptionLevel = .active
        // 通知を識別するための情報を追加
        content.userInfo = ["type": "deviceFound"]

        let request = UNNotificationRequest(
            identifier: "device-found-\(UUID().uuidString)",
            content: content,
            trigger: nil  // 即時配信
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Notification] Failed to send notification: \(error)")
            } else {
                print("[Notification] Notification sent for device: \(deviceName)")
            }
        }
    }

}

extension NotificationManager: UNUserNotificationCenterDelegate {
    // 通知をタップした時の処理
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let type = userInfo["type"] as? String, type == "deviceFound" {
            // "アガる報告"タブへの遷移をリクエスト
            DispatchQueue.main.async {
                self.pendingTabSelection = .age
            }
        }
        
        completionHandler()
    }
    
    // アプリがフォアグラウンドにある時の通知表示設定
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // フォアグラウンドでも通知を表示したい場合はここで設定（今回は表示しない設定のまま）
        completionHandler([.banner, .sound])
    }
}
