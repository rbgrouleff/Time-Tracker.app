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

    @Test func withoutStoppedAtIsRunning() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date.now)
        #expect(timingSession.isRunning)
    }

    @Test func withStoppedAtIsNotRunning() async throws {
        let timingSession = TimingSession(
            project: project,
            startedAt: Date.now,
            stoppedAt: Date.now
        )
        #expect(!timingSession.isRunning)
    }

    @Test func timingSessionDurationChangesWhenRunning() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date.now)
        let firstDuration = timingSession.duration
        sleep(1)
        #expect(timingSession.duration != firstDuration)
    }

    @Test func timingSessionDurationNotChangingWhenNotRunning() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date.now)
        timingSession.stoppedAt = Date.now
        let firstDuration = timingSession.duration
        sleep(1)
        #expect(timingSession.duration == firstDuration)
    }

    @Test func stopEndsTimingSession() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date.now)
        timingSession.stop()
        #expect(timingSession.stoppedAt != nil)
        #expect(!timingSession.isRunning)
    }
    
    @Test func stoppingAStoppedTimingSessionDoesNotChangeStoppedAt() async throws {
        let startedAt = Date(timeInterval: -3600, since: Date.now)
        let stoppedAt = Date(timeInterval: 100, since: startedAt)
        let timingSession = TimingSession(project: project, startedAt: startedAt, stoppedAt: stoppedAt)
        
        timingSession.stop()
        
        #expect(timingSession.stoppedAt == stoppedAt)
    }
    
    @Test func unbilledDurationIsZeroWhileRunning() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date(timeInterval: -3600, since: .now))
        
        #expect(timingSession.unbilledDuration == .zero)
    }

    @Test func invoicingARunningSessionFails() async throws {
        let timingSession = TimingSession(project: project, startedAt: Date.now)

        #expect(
            timingSession.invoiceDuration(Duration.zero)
                == .failure(.stillRunning)
        )
    }

    @Test func invoicingMoreThanDurationReturnsRemainingDuration() async throws
    {
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 600,since: now)
        )

        #expect(
            timingSession.invoiceDuration(Duration.seconds(3600))
                == .success(Duration.seconds(3000))
        )
    }

    @Test func invoicingExactDuration() async throws {
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )

        #expect(
            timingSession.invoiceDuration(Duration.seconds(3600))
                == .success(Duration.zero)
        )

        #expect(timingSession.invoicedDuration == Duration.seconds(3600))
    }

    @Test func invoicingUpdatesInvoicedDuration() async throws {
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )

        #expect(
            timingSession.invoiceDuration(Duration.seconds(600))
            == .success(Duration.zero)
        )

        #expect(timingSession.invoicedDuration == Duration.seconds(600))
    }

    @Test func invoicingRepeatedlyUpdatesInvoicedDuration() async throws {
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )

        _ = timingSession.invoiceDuration(Duration.seconds(600))
        _ = timingSession.invoiceDuration(Duration.seconds(600))

        #expect(timingSession.invoicedDuration == Duration.seconds(1200))
    }

    @Test func invoicingUpdatesUnbilledDuration() async throws {
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )

        _ = timingSession.invoiceDuration(Duration.seconds(600))

        #expect(
            timingSession.unbilledDuration == timingSession.duration
                - Duration.seconds(600)
        )
    }
    
    @Test func invoicingNegativeDuration() async throws {
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )
        
        timingSession.invoicedDuration = Duration.seconds(600)

        _ = timingSession.invoiceDuration(Duration.seconds(600) * -1)

        #expect(
            timingSession.invoicedDuration == Duration.zero
        )
    }
}
