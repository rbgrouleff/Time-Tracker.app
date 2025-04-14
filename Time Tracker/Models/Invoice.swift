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
    
    var duration: Duration {
        Duration.seconds(time)
    }

    convenience init(_ project: Project, time: TimeInterval) {
        self.init(project, time: time, paidAt: nil)
    }

    init(_ project: Project, time: TimeInterval, paidAt: Date?) {
        self.project = project
        self.time = time
        self.paidAt = paidAt
    }
}
