//
//  ThreeColumnContentView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 21/02/2025.
//

import SwiftUI

struct ThreeColumnContentView: View {
    @Environment(NavigationContext.self) private var navigationContext:
        NavigationContext
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    var body: some View {
        @Bindable var navigationContext = navigationContext
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ClientListView().navigationTitle("Clients")
        } content: {
            ProjectListView(client: navigationContext.selectedClient)
                .navigationTitle(navigationContext.contentListTitle)
                .environment(navigationContext)
        } detail: {
            ProjectDetailView(project: navigationContext.selectedProject)
                .environment(navigationContext)
                .toolbar {
                    HStack {
                        TimingSessionButton()
                        if let timingSession = navigationContext
                            .runningTimingSession
                        {
                            Text(
                                "\(timingSession.project.client.name) » \(timingSession.project.name)"
                            )
                        }
                    }
                }
        }
    }
}

private struct TimingSessionButton: View {
    @Environment(NavigationContext.self) private var navigationContext:
        NavigationContext
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        if navigationContext.timerRunning {
            Button {
                stopTimingSession()
            } label: {
                Label("Stop timer", systemImage: "stop.fill")
                    .help("Stop timer")
            }
        } else {
            Button {
                startTimingSession()
            } label: {
                Label("Start timer", systemImage: "play.fill")
                    .help("Start timer")
            }
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
