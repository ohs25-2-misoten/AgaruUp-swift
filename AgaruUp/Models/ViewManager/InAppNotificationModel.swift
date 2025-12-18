//
//  InAppNotificationModel.swift
//  AgaruUp
//
//  Created by 拓実 on 2025/12/18.
//

import SwiftUI
import Combine

final class InAppNotificationModel: ObservableObject {

    @Published var isVisible: Bool = false
    @Published var message: String = ""

    func show(message: String) {
        self.message = message
        self.isVisible = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isVisible = false
        }
    }
}
