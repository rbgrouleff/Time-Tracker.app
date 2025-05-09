//
//  TimingSessionButton.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 08/05/2025.
//

import SwiftUI

struct TimingSessionButtonView: View {
    @Environment(NavigationContext.self) private var navigationContext:
        NavigationContext
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if navigationContext.timerRunning {
            Button("Stop timer", systemImage: "stop.fill", action: stopTimingSession)
                .help("Stop timer")
                .keyboardShortcut(.space, modifiers: [])
        } else {
            Button("Start timer", systemImage: "play.fill", action: startTimingSession)
                .help("Start timer")
                .keyboardShortcut(.space, modifiers: [])
                .disabled(
                    navigationContext.selectedProject == nil
                        && !navigationContext.timerRunning
                )
        }
    }

    private func startTimingSession() {
        if navigationContext.timerRunning {
            stopTimingSession()
        }
        if let project = navigationContext.selectedProject {
            let timingSession = TimingSession(
                project: project,
                startedAt: .now
            )
            project.timingSessions.append(timingSession)
            modelContext.insert(timingSession)
            try! modelContext.save()
            navigationContext.runningTimingSession = timingSession
        }
    }

    private func stopTimingSession() {
        if let timingSession = navigationContext.runningTimingSession {
            timingSession.stop()
            navigationContext.runningTimingSession = nil
        }
    }
}
