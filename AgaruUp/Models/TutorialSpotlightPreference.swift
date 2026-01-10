//
//  TutorialSpotlightPreference.swift
//  AgaruUp
//
//  Created by AI Assistant on 2026/01/11.
//

import SwiftUI

// MARK: - フィード画面用

struct FeedSpotlightPreferenceKey: PreferenceKey {
    static var defaultValue: [FeedTutorialStep: CGRect] = [:]
    
    static func reduce(value: inout [FeedTutorialStep: CGRect], nextValue: () -> [FeedTutorialStep: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct FeedSpotlightModifier: ViewModifier {
    let step: FeedTutorialStep
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: FeedSpotlightPreferenceKey.self,
                            value: [step: geometry.frame(in: .global)]
                        )
                }
            )
    }
}

extension View {
    func feedSpotlight(for step: FeedTutorialStep) -> some View {
        modifier(FeedSpotlightModifier(step: step))
    }
}

// MARK: - アガる報告画面用

struct AgeSpotlightPreferenceKey: PreferenceKey {
    static var defaultValue: [AgeTutorialStep: CGRect] = [:]
    
    static func reduce(value: inout [AgeTutorialStep: CGRect], nextValue: () -> [AgeTutorialStep: CGRect]) {
        value.merge(nextValue()) { _, new in new }
    }
}

struct AgeSpotlightModifier: ViewModifier {
    let step: AgeTutorialStep
    
    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(
                            key: AgeSpotlightPreferenceKey.self,
                            value: [step: geometry.frame(in: .global)]
                        )
                }
            )
    }
}

extension View {
    func ageSpotlight(for step: AgeTutorialStep) -> some View {
        modifier(AgeSpotlightModifier(step: step))
    }
}
