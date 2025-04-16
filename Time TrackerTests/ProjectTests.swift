//
//  ProjectTests.swift
//  Time TrackerTests
//
//  Created by Rasmus Bang Grouleff on 07/04/2025.
//

import Foundation
import Testing

@testable import Time_Tracker

@Suite("Project tests") struct ProjectTests {
    var client: Client

    init() {
        self.client = Client(name: "Test Client")
    }

    @Test func projectUnbilledSessionsIncludeAllWhenThereAreNoInvoices()
        async throws
    {
        let project = Project(name: "Test project", client: client)
        let timingSessions = [
            TimingSession(
                project: project,
                startedAt: Date(),
                stoppedAt: Date(timeIntervalSinceNow: 3600)
            )
        ]
        project.timingSessions.append(timingSessions.first!)

        #expect(project.unbilledTimingSessions.elementsEqual(timingSessions))
    }

    @Test
    func
        projectUnbilledSessionsIncludesSessionWhenSessionDurationIsLongerThanRemainingInvoicedDuration()
        async throws
    {
        let project = Project(name: "Test project", client: client)
        let timingSessions = [
            TimingSession(
                project: project,
                startedAt: Date(),
                stoppedAt: Date(timeIntervalSinceNow: 3600)
            )
        ]
        project.timingSessions.append(timingSessions.first!)

        let _ = project.createInvoice(time: 60, date: .now, due: .now, number: 1)

        #expect(project.unbilledTimingSessions.elementsEqual(timingSessions))
    }

    @Test
    func
        projectUnbilledSessionsExcludesSessionWhenSessionDurationIsEqualToRemainingInvoicedDuration()
        async throws
    {
        let project = Project(name: "Test project", client: client)
        let timingSessions = [
            TimingSession(
                project: project,
                startedAt: Date(),
                stoppedAt: Date(timeIntervalSinceNow: 3600)
            )
        ]
        project.timingSessions.append(timingSessions.first!)

        let _ = project.createInvoice(time: 3600, date: .now, due: .now, number: 1)

        #expect(project.unbilledTimingSessions.isEmpty)
    }

    @Test func projectUnbilledSessionsExcludesOldestSessions() async throws {
        let project = Project(name: "Test project", client: client)
        let now = Date.now
        project.timingSessions = [
            TimingSession(
                project: project,
                startedAt: now,
                stoppedAt: Date(timeInterval: 3600, since: now)
            ),
            TimingSession(
                project: project,
                startedAt: Date(timeInterval: 7200, since: now),
                stoppedAt: Date(timeInterval: 10800, since: now)
            ),
        ]
        
        #expect(project.unbilledTimingSessions.elementsEqual(project.timingSessions))

        _ = project.createInvoice(time: 3600, date: .now, due: .now, number: 1)

        #expect(
            project.unbilledTimingSessions.elementsEqual([
                project.timingSessions.last!
            ])
        )
    }

    @Test func projectCreateInvoiceCannotInoviceMoreThanUnbilledTime()
        async throws
    {
        let project = Project(name: "Test project", client: client)

        let result = project.createInvoice(time: 10, date: .now, due: .now, number: 1)

        #expect(result == .failure(.insufficientUnbilledTime))
    }

    @Test func projectCreateInvoiceCreatesAnInvoice() async throws {
        let project = Project(name: "Test project", client: client)
        let now = Date.now
        project.timingSessions.append(
            TimingSession(
                project: project,
                startedAt: now,
                stoppedAt: Date(timeInterval: 3600, since: now)
            )
        )

        let result = project.createInvoice(time: 3600, date: .now, due: .now, number: 1)

        #expect(result == .success(project.invoices.last!))
    }

    @Test func projectCreateInvoiceChangesUnbilledDuration() async throws {
        let project = Project(name: "Test project", client: client)
        let now = Date.now
        project.timingSessions.append(
            TimingSession(
                project: project,
                startedAt: now,
                stoppedAt: Date(timeInterval: 3600, since: now)
            )
        )

        let unbilledDuration = project.unbilledDuration

        let time = 3600.0

        let _ = project.createInvoice(time: time, date: .now, due: .now, number: 1)

        #expect(
            project.unbilledDuration == unbilledDuration
                - Duration.seconds(time)
        )
    }

    @Test func projectCreateInvoiceAddsTimingSessionToInvoicedTimingSessions()
        async throws
    {
        let project = Project(name: "Test project", client: client)
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )
        project.timingSessions.append(
            timingSession
        )

        let time = 3600.0

        let _ = project.createInvoice(time: time, date: .now, due: .now, number: 1)
        
        #expect(project.invoicedTimingSessions.contains(timingSession))
    }

    @Test
    func projectCreateInvoiceRemovesTimingSessionFromUnbilledTimingSessions()
        async throws
    {
        let project = Project(name: "Test project", client: client)
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )
        project.timingSessions.append(
            timingSession
        )

        let time = 3600.0

        let _ = project.createInvoice(time: time, date: .now, due: .now, number: 1)
        
        #expect(!project.unbilledTimingSessions.contains(timingSession))
    }

    @Test
    func
        projectCreateInvoiceDoesNotAddTimingSessionToInvoicedTimingSessions()
        async throws
    {
        let project = Project(name: "Test project", client: client)
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )
        project.timingSessions.append(
            timingSession
        )

        let time = 600.0

        let _ = project.createInvoice(time: time, date: .now, due: .now, number: 1)
        
        #expect(!project.invoicedTimingSessions.contains(timingSession))
    }
    
    @Test
    func
        projectCreateInvoiceDoesNotRemoveTimingSessionFromUnbilledTimingSessions()
        async throws
    {
        let project = Project(name: "Test project", client: client)
        let now = Date.now
        let timingSession = TimingSession(
            project: project,
            startedAt: now,
            stoppedAt: Date(timeInterval: 3600, since: now)
        )
        project.timingSessions.append(
            timingSession
        )

        let time = 600.0

        let _ = project.createInvoice(time: time, date: .now, due: .now, number: 1)
        
        #expect(project.unbilledTimingSessions.contains(timingSession))
    }
}
