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
        get {
            Duration.seconds(invoicedTime)
        }
        set(d) {
            invoicedTime = TimeInterval(d.components.seconds)
        }
    }
    
    var isRunning: Bool {
        stoppedAt == nil
    }
    
    var isUnbilled: Bool {
        unbilledDuration > Duration.zero
    }
    
    var duration: Duration {
        let interval =
        if let stoppedAt {
            DateInterval(start: startedAt, end: stoppedAt)
        } else {
            DateInterval(start: startedAt, end: Date.now)
        }
        return Duration.seconds(interval.duration)
    }
    
    var unbilledDuration: Duration {
        duration - invoicedDuration
    }
    
    var description: String {
        "Started: \(startedAt), stopped: \(String(describing: stoppedAt))"
    }
    
    convenience init(
        project: Project,
        startedAt: Date,
    ) {
        self.init(project: project, startedAt: startedAt, stoppedAt: nil, invoicedDuration: Duration.zero)
    }
    
    convenience init(project: Project, startedAt: Date, stoppedAt: Date) {
        self.init(project: project, startedAt: startedAt, stoppedAt: stoppedAt, invoicedDuration: Duration.zero)
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
        self.stoppedAt = Date.now
    }
    
    // Returns what remains of the given duration after invoicing as much as possible
    func invoiceDuration(_ durationToInvoice: Duration) -> Result<Duration, TimingSessionError> {
        guard !isRunning else {
            return .failure(.stillRunning)
        }
        if durationToInvoice <= unbilledDuration {
            invoicedDuration += durationToInvoice
            return .success(Duration.zero)
        } else {
            let difference = durationToInvoice - unbilledDuration
            invoicedDuration = duration
            return .success(difference)
        }
    }
}

//extension TimingSession: Identifiable {}

enum TimingSessionError: Error {
    case invoiceDurationExceedsUnbilledDuration
    case stillRunning
}
