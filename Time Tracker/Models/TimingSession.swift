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

    var isRunning: Bool {
        stoppedAt == nil
    }

    var duration: Duration {
        let interval = if let stoppedAt {
            DateInterval(start: startedAt, end: stoppedAt)
        } else {
            DateInterval(start: startedAt, end: Date())
        }
        return Duration.seconds(interval.duration)
    }

    init(project: Project, startedAt: Date) {
        self.project = project
        self.startedAt = startedAt
    }

    func stop() {
        self.stoppedAt = Date()
    }
}

extension TimingSession: Identifiable {}
