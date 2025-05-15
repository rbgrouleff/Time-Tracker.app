//
//  TimingSessionTableView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 20/03/2025.
//

import SwiftData
import SwiftUI

struct TimingSessionTableView: View {
    @Environment(NavigationContext.self) private var navigationContext:
        NavigationContext
    var timingSessions: [TimingSession]

    init(timingSessions: [TimingSession]) {
        self.timingSessions = timingSessions
    }

    var body: some View {
        @Bindable var navigationContext = navigationContext
        Table(
            timingSessions,
            selection: $navigationContext.selectedTimingSession
        ) {
            TableColumn("Started at") { timingSession in
                Text(
                    timingSession.startedAt,
                    format: .dateTime.day().month().year().hour().minute()
                        .second()
                )
            }
            TableColumn("Stopped at") { timingSession in
                if let stoppedAt = timingSession.stoppedAt {
                    Text(
                        stoppedAt,
                        format: .dateTime.day().month().year().hour().minute()
                            .second()
                    )
                } else {
                    Text("-")
                }
            }
            TableColumn("Duration") { timingSession in
                if timingSession.isRunning {
                    Text(timingSession.startedAt, style: .timer)
                } else {
                    Text(
                        timingSession.duration,
                        format: .time(pattern: .hourMinuteSecond)
                    )
                }
            }
            TableColumn("Unbilled duration") { timingSession in
                if timingSession.isRunning {
                    Text("-")
                } else {
                    Text(
                        timingSession.unbilledDuration,
                        format: .time(pattern: .hourMinuteSecond)
                    )
                }
            }
        }
    }
}

#Preview {
    TimingSessionTableView(timingSessions: [])
        .environment(NavigationContext())
}
