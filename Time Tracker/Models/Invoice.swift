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
    var number: Int

    var isPaid: Bool {
        get {
            paidAt != nil
        }
        set(paid) {
            if paidAt == nil && paid {
                paidAt = .now
            }
        }
    }
    
    var isOverdue: Bool {
        !isPaid && due < .now
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
        self.number = number
        self.year = date.formatted(.dateTime.year())
    }
    
    static func nextNumber(modelContext: ModelContext, date: Date) -> Result<Int, Error> {
        let year = date.formatted(.dateTime.year())
        var descriptor = FetchDescriptor<Invoice>(predicate: #Predicate { $0.year == year }, sortBy: [.init(\.number, order: .reverse)])
        descriptor.fetchLimit = 1
        guard let invoices = try? modelContext.fetch(descriptor) else {
            return .failure(.lookupFailed)
        }
        guard let last = invoices.first else {
            return .success(1)
        }
        return .success(last.number + 1)
    }
    
    enum Error: Swift.Error {
        case lookupFailed
        case createFailed
    }
}
