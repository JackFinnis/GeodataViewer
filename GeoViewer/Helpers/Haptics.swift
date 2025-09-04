//
//  Haptics.swift
//  Paddle
//
//  Created by Jack Finnis on 12/09/2022.
//

import UIKit

@MainActor
struct Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }
    
    static func success() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
    
    static func error() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
