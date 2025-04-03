//
//  TimingSessionTests.swift
//  Time TrackerTests
//
//  Created by Rasmus Bang Grouleff on 20/03/2025.
//

import Foundation
import Testing

@testable import Time_Tracker

@Suite("Timing session tests") struct TimingSessionTests {
    var project: Project

    init() {
        let client = Client(name: "Test client")
        self.project = Project(name: "Test project", client: client)
    }

    @Test func timingSessionIsRunning() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date())
        #expect(timingSession.isRunning)
    }

    @Test func timingSessionDurationChangesWhenRunning() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date())
        let firstDuration = timingSession.duration
        sleep(1)
        #expect(timingSession.duration != firstDuration)
    }

    @Test func timingSessionDurationNotChangingWhenNotRunning() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date())
        timingSession.stoppedAt = Date()
        let firstDuration = timingSession.duration
        sleep(1)
        #expect(timingSession.duration == firstDuration)
    }

    @Test func stopEndsTimingSession() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date())
        timingSession.stop()
        #expect(timingSession.stoppedAt != nil)
        #expect(!timingSession.isRunning)
    }
}
