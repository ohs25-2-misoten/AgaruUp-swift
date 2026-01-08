//
//  NotificationManager.swift
//  AgaruUp
//
//  Created on 2026/01/09.
//

import Foundation
import UserNotifications
import UIKit

/// ローカル通知を管理するマネージャー
@Observable
final class NotificationManager: NSObject {
    static let shared = NotificationManager()
    
    /// 通知が許可されているかどうか
    var isAuthorized: Bool = false
    
    private override init() {
        super.init()
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
    
    /// デバイス発見時の通知を送信（デバッグ用：フォアグラウンドでも送信）
    func sendDeviceFoundNotification(deviceName: String, distance: Double? = nil) {
        guard isAuthorized else {
            print("[Notification] Not authorized, skipping notification")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "カメラを発見！📸"
        if let distance = distance {
            content.body = "\(deviceName) が \(String(format: "%.2f", distance))m の距離にあります"
        } else {
            content.body = "\(deviceName) を発見しました！"
        }
        content.sound = .default
        content.interruptionLevel = .active
        
        let request = UNNotificationRequest(
            identifier: "device-found-\(UUID().uuidString)",
            content: content,
            trigger: nil // 即時配信
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Notification] Failed to send notification: \(error)")
            } else {
                print("[Notification] Notification sent for device: \(deviceName)")
            }
        }
    }
    
    /// スキャン開始時の通知を送信（デバッグ用）
    func sendScanStartedNotification() {
        guard isAuthorized else {
            print("[Notification] Not authorized, skipping notification")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "BLEスキャン開始 �"
        content.body = "rpi-camera を探しています..."
        content.sound = .default
        content.interruptionLevel = .active
        
        let request = UNNotificationRequest(
            identifier: "scan-started-\(UUID().uuidString)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[Notification] Failed to send scan notification: \(error)")
            } else {
                print("[Notification] Scan started notification sent")
            }
        }
    }
}
