//
//  NavigationContext.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 08/02/2025.
//

import SwiftUI

@Observable
final class NavigationContext {
    var selectedClient: Client?
    var selectedProject: Project?
    var runningTimingSession: TimingSession?
    
    var isTimingSessionEditorPresented = false

    var selectedTimingSession: TimingSession.ID? {
        get {
            if let runningTimingSession, let selectedProject {
                if runningTimingSession.project == selectedProject {
                    return runningTimingSession.id
                }
            }
            return nil
        }
        set(timingSessionId) {
            if !timerRunning {
                if let selectedProject,
                    let timingSession = selectedProject.timingSessions.first(
                        where: { timingSession in
                            timingSession.id == timingSessionId
                        })
                {

                    if timingSession.isRunning {
                        runningTimingSession = timingSession
                    }

                }
            }
        }
    }

    var timerRunning: Bool {
        runningTimingSession != nil
    }

    var contentListTitle: String {
        if let selectedClient {
            selectedClient.name
        } else {
            ""
        }
    }

//    init(
//        columnVisibility: NavigationSplitViewVisibility = .automatic
//    ) {
//        self.columnVisibility = columnVisibility
//    }
}
