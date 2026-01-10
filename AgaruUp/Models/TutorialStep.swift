//
//  TutorialStep.swift
//  AgaruUp
//
//  Created by AI Assistant on 2026/01/11.
//

import SwiftUI

// MARK: - フィード画面チュートリアル

enum FeedTutorialStep: Int, CaseIterable {
    case swipe = 0
    case tap
    case download
    
    var message: String {
        switch self {
        case .swipe:
            return "上下スワイプで\n動画を切り替え"
        case .tap:
            return "タップで再生/停止"
        case .download:
            return "ここから動画を\n保存できます"
        }
    }
    
    var tooltipPosition: TooltipPosition {
        switch self {
        case .swipe, .tap:
            return .bottom
        case .download:
            return .left
        }
    }
    
    var spotlightShape: SpotlightShape {
        switch self {
        case .swipe:
            return .roundedRectangle
        default:
            return .roundedRectangle
        }
    }
    
    var next: FeedTutorialStep? {
        let allCases = FeedTutorialStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex + 1 < allCases.count else {
            return nil
        }
        return allCases[currentIndex + 1]
    }
    
    var previous: FeedTutorialStep? {
        let allCases = FeedTutorialStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex > 0 else {
            return nil
        }
        return allCases[currentIndex - 1]
    }
}

// MARK: - アガる報告画面チュートリアル

enum AgeTutorialStep: Int, CaseIterable {
    case cameraToggle = 0
    case progressBar
    case button
    
    var message: String {
        switch self {
        case .cameraToggle:
            return "まずカメラ検出を\nONにしよう"
        case .progressBar:
            return "これがアゲ報告の\n進捗バー"
        case .button:
            return "ボタン連打で100%に\nしてアゲ報告！"
        }
    }
    
    var tooltipPosition: TooltipPosition {
        switch self {
        case .cameraToggle:
            return .top
        case .progressBar, .button:
            return .bottom
        }
    }
    
    var spotlightShape: SpotlightShape {
        .roundedRectangle
    }
    
    var next: AgeTutorialStep? {
        let allCases = AgeTutorialStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex + 1 < allCases.count else {
            return nil
        }
        return allCases[currentIndex + 1]
    }
    
    var previous: AgeTutorialStep? {
        let allCases = AgeTutorialStep.allCases
        guard let currentIndex = allCases.firstIndex(of: self),
              currentIndex > 0 else {
            return nil
        }
        return allCases[currentIndex - 1]
    }
}

// MARK: - 共通型

/// 吹き出しの表示位置
enum TooltipPosition {
    case top
    case bottom
    case left
    case right
    case center
}

/// スポットライトの形状
enum SpotlightShape {
    case ellipse
    case roundedRectangle
}
