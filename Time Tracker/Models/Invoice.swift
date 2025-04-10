//
//  Invoice.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 07/04/2025.
//

import Foundation
import SwiftData

@Model
final class Invoice {
    var project: Project
    var time: TimeInterval
    var paidAt: Date?
    
    var isPaid: Bool {
        get {
            paidAt != nil
        }
        set(paid) {
            if paidAt == nil && paid {
                paidAt = Date.now
            }
        }
    }

    init(_ project: Project, time: TimeInterval, paidAt: Date? = nil) {
        self.project = project
        self.time = time
        self.paidAt = paidAt
    }
}
