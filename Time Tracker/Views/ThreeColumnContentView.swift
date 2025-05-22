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
    @Environment(\.modelContext) private var modelContext
    
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
            ProjectDetailView(project: navigationContext.selectedProject, isTimingSessionEditorPresented: $navigationContext.isTimingSessionEditorPresented)
                .environment(navigationContext)
                .toolbar {
                    HStack {
                        TimingSessionButtonView()
                        if let timingSession = navigationContext
                            .runningTimingSession
                        {
                            Text(
                                "\(timingSession.project?.client?.name ?? "NOPE!") » \(timingSession.project?.name ?? "NOPE!")"
                            )
                        }
                    }
                }
        }
    }
}


