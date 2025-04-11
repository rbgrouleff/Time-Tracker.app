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
        switch updateTimingSessions(Duration.seconds(time)) {
        case .success(()):
            if let modelContext {
                modelContext.insert(invoice)
            }
            return .success(invoice)
        case .failure(let err):
            if let modelContext {
                modelContext.delete(invoice)
            }
            return .failure(err)
        }

    }

    private func updateTimingSessions(_ duration: Duration) -> Result<
        (), ProjectError
    > {
        var duration = duration
        var changes: [TimingSession: Duration] = [:]

        for session in unbilledTimingSessions {
            guard !session.isRunning else { break }

            switch session.invoiceDuration(duration) {
            case .success(let remainingDuration):
                changes.updateValue(
                    duration - remainingDuration,
                    forKey: session
                )
                duration = remainingDuration
                if remainingDuration == Duration.zero {
                    break
                }
            case .failure(_):
                break
            }
        }

        if duration == .zero {
            return .success(())
        } else {
            revertInvoicing(changes: changes)
            return .failure(.invoicingFailed)
        }
    }

    private func revertInvoicing(changes: [TimingSession: Duration]) {
        changes.reversed().forEach { (session, duration) in
            _ = session.invoiceDuration(duration * -1)
        }
    }
}

enum ProjectError: Error {
    case insufficientUnbilledTime
    case invoicingFailed
}
