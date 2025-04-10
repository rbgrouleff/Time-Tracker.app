//
//  Project.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 30/01/2025.
//

import Foundation
import SwiftData

@Model
final class Project {
    var name: String
    var client: Client

    @Relationship(deleteRule: .cascade, inverse: \TimingSession.project)
    var timingSessions = [TimingSession]()

    @Relationship(deleteRule: .cascade, inverse: \Invoice.project)
    var invoices = [Invoice]()

    var invoicedTimingSessions: [TimingSession] {
        timingSessions.filter { !$0.isUnbilled }
    }

    var unbilledDuration: Duration {
        timingSessions.reduce(into: Duration.zero) { $0 += $1.unbilledDuration }
    }

    var unbilledTimingSessions: [TimingSession] {
        timingSessions.filter { $0.isUnbilled }
    }

    init(name: String, client: Client) {
        self.name = name
        self.client = client
    }

    func createInvoice(time: TimeInterval) -> Result<Invoice, ProjectError> {
        guard Duration.seconds(time) <= unbilledDuration else {
            return .failure(.insufficientUnbilledTime)
        }

        let invoice = Invoice(self, time: time)
        updateInvoicedTimingSessions(Duration.seconds(time))
        invoices.append(invoice)
        return .success(invoice)
    }

    private func updateInvoicedTimingSessions(_ duration: Duration) {
        var duration = duration

        // TODO: Figure out how to roll back any changes, if a session returns a failure.
        for session in unbilledTimingSessions {
            guard !session.isRunning else { return }

            switch session.invoiceDuration(duration) {
            case .success(let remainingDuration):
                if remainingDuration == Duration.zero {
                    return
                }
                duration = remainingDuration
            case .failure(_):
                return
            }
        }
    }
}

enum ProjectError: Error {
    case insufficientUnbilledTime
    case invoicingFailed
}
