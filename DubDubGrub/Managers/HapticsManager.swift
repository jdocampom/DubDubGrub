//
//  HapticsManager.swift
//  DubDubGrub
//
//  Created by Juan Diego Ocampo on 9/03/22.
//

import UIKit

struct HapticManager {
    static func playSuccessHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func playErrorHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}
