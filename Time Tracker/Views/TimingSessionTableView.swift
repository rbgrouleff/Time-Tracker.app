//
//  TimingSessionTableView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 20/03/2025.
//

import SwiftUI
import SwiftData

struct TimingSessionTableView: View {
    @Environment(NavigationContext.self) private var navigationContext: NavigationContext
    var timingSessions: [TimingSession]
    private var time: Time
    
    init(timingSessions: [TimingSession], time: Time = Time()) {
        self.timingSessions = timingSessions
        self.time = time
    }

    var body: some View {
        @Bindable var navigationContext = navigationContext
        Table(timingSessions, selection: $navigationContext.selectedTimingSession) {
            TableColumn("Started at") { timingSession in
                Text(timingSession.startedAt, format: .dateTime.day().month().year().hour().minute().second())
            }
            TableColumn("Stopped at") { timingSession in
                if let stoppedAt = timingSession.stoppedAt {
                    Text(stoppedAt, format: .dateTime.day().month().year().hour().minute().second())
                } else {
                    Text("-")
                }
            }
            TableColumn("Duration") { timingSession in
                RunningDurationView(timingSession: timingSession, time: time)
            }
            TableColumn("Unbilled duration") { timingSession in
                if timingSession.isRunning {
                    Text("-")
                } else {
                    Text(timingSession.unbilledDuration, format: .units(allowed: [.hours, .minutes, .seconds], width: .narrow, zeroValueUnits: .show(length: 2)))
                }
            }
        }
    }
}

private struct RunningDurationView: View {
    var timingSession: TimingSession
    var time: Time
    @State private var duration: Duration

    init(timingSession: TimingSession, time: Time) {
        self.timingSession = timingSession
        self.duration = timingSession.duration
        self.time = time
    }

    var body: some View {
        Text(duration, format: .units(allowed: [.hours, .minutes, .seconds], width: .narrow, zeroValueUnits: .show(length: 2)))
            .onReceive(time.tick) { _ in
                if timingSession.isRunning {
                    duration = timingSession.duration
                }
            }
    }
}

#Preview {
    let client = Client(name: "Client")
    let project = Project(name: "Project", client: client)
    let time = Time()
    RunningDurationView(timingSession: TimingSession(project: project, startedAt: .now), time: time)
}

#Preview {
    TimingSessionTableView(timingSessions: [])
        .environment(NavigationContext())
}
