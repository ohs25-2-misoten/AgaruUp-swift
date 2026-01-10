//
//  TutorialManager.swift
//  AgaruUp
//
//  Created by AI Assistant on 2026/01/11.
//

import SwiftUI

/// フィード画面チュートリアルの状態を管理
@Observable
final class FeedTutorialManager {
    static let shared = FeedTutorialManager()
    
    var hasCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedFeedTutorial") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedFeedTutorial") }
    }
    
    var isShowing: Bool = false
    var currentStep: FeedTutorialStep = .swipe
    
    private init() {}
    
    func start() {
        guard !hasCompleted else { return }
        currentStep = .swipe
        isShowing = true
    }
    
    func nextStep() {
        if let next = currentStep.next {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = next
            }
        } else {
            complete()
        }
    }
    
    func previousStep() {
        if let previous = currentStep.previous {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = previous
            }
        }
    }
    
    func skip() {
        complete()
    }
    
    private func complete() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
        hasCompleted = true
    }
    
    func reset() {
        hasCompleted = false
        currentStep = .swipe
    }
}

/// アガる報告画面チュートリアルの状態を管理
@Observable
final class AgeTutorialManager {
    static let shared = AgeTutorialManager()
    
    var hasCompleted: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedAgeTutorial") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedAgeTutorial") }
    }
    
    var isShowing: Bool = false
    var currentStep: AgeTutorialStep = .cameraToggle
    
    private init() {}
    
    func start() {
        guard !hasCompleted else { return }
        currentStep = .cameraToggle
        isShowing = true
    }
    
    func nextStep() {
        if let next = currentStep.next {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = next
            }
        } else {
            complete()
        }
    }
    
    func previousStep() {
        if let previous = currentStep.previous {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = previous
            }
        }
    }
    
    func skip() {
        complete()
    }
    
    private func complete() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
        }
        hasCompleted = true
    }
    
    func reset() {
        hasCompleted = false
        currentStep = .cameraToggle
    }
}
