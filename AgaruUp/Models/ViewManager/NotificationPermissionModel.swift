//
//  NotificationPermissionModel.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/12/18.
//

import UserNotifications

final class NotificationPermissionModel {

    private let hasRequestedKey = "hasRequestedNotificationPermission"

    func requestPermissionIfNeeded() {
        let hasRequested = UserDefaults.standard.bool(forKey: hasRequestedKey)
        guard !hasRequested else { return }

        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                UserDefaults.standard.set(true, forKey: self.hasRequestedKey)
                print("🔔 Notification permission:", granted)
            }
    }
}
