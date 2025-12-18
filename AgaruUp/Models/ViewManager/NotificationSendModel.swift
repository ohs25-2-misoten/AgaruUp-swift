//
//  NotificationSendModel.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/12/18.
//

import UserNotifications

final class NotificationSendModel {

    func sendCompletedNotification() {
        let content = UNMutableNotificationContent()
        content.title = "おめでとう！"
        content.body = "アガりメーターが100%になりました 🎉"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}
