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
    #Unique<Invoice>([\.year, \.number])

    var project: Project
    var time: TimeInterval
    var date: Date
    var due: Date
    var paidAt: Date?

    var year: String
    var number: String

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

    convenience init(
        _ project: Project,
        time: TimeInterval,
        date: Date,
        due: Date,
        number: Int
    ) {
        self.init(
            project,
            time: time,
            date: date,
            due: due,
            paidAt: nil,
            number: number
        )
    }

    init(
        _ project: Project,
        time: TimeInterval,
        date: Date,
        due: Date,
        paidAt: Date?,
        number: Int
    ) {
        self.project = project
        self.time = time
        self.date = date
        self.due = due
        self.paidAt = paidAt
        self.number = number.formatted()
        self.year = date.formatted(.dateTime.year())
    }
}
