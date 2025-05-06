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

    func createInvoice(time: TimeInterval, date: Date, due: Date, number: Int) -> Result<Invoice, Error> {
        guard Duration.seconds(time) <= unbilledDuration else {
            return .failure(.insufficientUnbilledTime)
        }

        let invoice = Invoice(self, time: time, date: date, due: due, number: number)
        switch updateTimingSessions(time) {
        case .success(()):
            if let modelContext {
                modelContext.insert(invoice)
            }
            invoices.append(invoice)
            return .success(invoice)
        case .failure(let err):
            if let modelContext {
                modelContext.delete(invoice)
            }
            return .failure(err)
        }

    }

    private func updateTimingSessions(_ time: TimeInterval) -> Result<
        (), Error
    > {
        var time = time
        var changes: [TimingSession: TimeInterval] = [:]

        for session in unbilledTimingSessions {
            guard !session.isRunning else { break }

            switch session.invoiceDuration(time) {
            case .success(let remainingTime):
                changes.updateValue(
                    time - remainingTime,
                    forKey: session
                )
                time = remainingTime
                if remainingTime == 0 {
                    break
                }
            case .failure(_):
                break
            }
        }

        if time == 0 {
            return .success(())
        } else {
            revertInvoicing(changes: changes)
            return .failure(.invoicingFailed)
        }
    }

    private func revertInvoicing(changes: [TimingSession: TimeInterval]) {
        changes.reversed().forEach { (session, time) in
            _ = session.invoiceDuration(time * -1)
        }
    }
    
    enum Error: Swift.Error {
        case insufficientUnbilledTime
        case invoicingFailed
    }
}
