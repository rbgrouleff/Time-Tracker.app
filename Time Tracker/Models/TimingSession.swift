//
//  TimingSession.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 20/03/2025.
//

import Foundation
import SwiftData

@Model
final class TimingSession {
    var project: Project
    
    var startedAt: Date
    var stoppedAt: Date?
    var invoicedTime: TimeInterval

    var invoicedDuration: Duration {
        Duration.seconds(invoicedTime)
    }
    
    var isRunning: Bool {
        stoppedAt == nil
    }
    
    var isUnbilled: Bool {
        unbilledDuration > .zero || isRunning
    }
    
    var duration: Duration {
        return Duration.seconds(time)
    }
    
    var unbilledDuration: Duration {
        Duration.seconds(unbilledTime)
    }
    
    var description: String {
        "Started: \(startedAt), stopped: \(String(describing: stoppedAt))"
    }
    
    convenience init(
        project: Project,
        startedAt: Date,
    ) {
        self.init(project: project, startedAt: startedAt, stoppedAt: nil, invoicedDuration: .zero)
    }
    
    convenience init(project: Project, startedAt: Date, stoppedAt: Date) {
        self.init(project: project, startedAt: startedAt, stoppedAt: stoppedAt, invoicedDuration: .zero)
    }
    
    init(
        project: Project,
        startedAt: Date,
        stoppedAt: Date?,
        invoicedDuration: Duration
    ) {
        self.project = project
        self.startedAt = startedAt
        self.stoppedAt = stoppedAt
        self.invoicedTime = TimeInterval(invoicedDuration.components.seconds)
    }
    
    func stop() {
        guard stoppedAt == nil else {
            return
        }
        self.stoppedAt = .now
    }
    
    // Returns what remains of the given duration after invoicing as much as possible
    func invoiceDuration(_ timeToInvoice: TimeInterval) -> Result<TimeInterval, TimingSessionError> {
        guard !isRunning else {
            return .failure(.stillRunning)
        }
        if timeToInvoice <= unbilledTime {
            invoicedTime += timeToInvoice
            return .success(.zero)
        } else {
            let difference = timeToInvoice - unbilledTime
            invoicedTime = time
            return .success(difference)
        }
    }
    
    private var unbilledTime: TimeInterval {
        if isRunning {
            0
        } else {
            time - invoicedTime
        }
    }
    
    private var time: TimeInterval {
        if let stoppedAt {
            startedAt.distance(to: stoppedAt)
        } else {
            startedAt.distance(to: .now)
        }
    }
}

//extension TimingSession: Identifiable {}

enum TimingSessionError: Error {
    case invoiceDurationExceedsUnbilledDuration
    case stillRunning
}
