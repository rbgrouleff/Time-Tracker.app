//
//  ProjectDetailsView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 27/02/2025.
//

import SwiftUI

struct ProjectDetailView: View {
    var project: Project?

    var body: some View {
        if let project {
            ProjectDetailContentView(project: project)
                .navigationTitle("\(project.name)")
        } else {
            ContentUnavailableView(
                "Select a project",
                systemImage: "calendar.badge.clock"
            )
        }
    }
}

private struct ProjectDetailContentView: View {
    var project: Project

    var body: some View {
        VStack {
            Text(project.name)
                .font(.title)
                .padding()

            ProjectTabView(project: project)
        }
    }
}

private struct ProjectTabView: View {
    var project: Project

    var body: some View {
        TabView {
            Tab("Timing sessions", systemImage: "timer") {
                TimingSessionTableView(timingSessions: project.timingSessions)
            }
            Tab("Billing", systemImage: "wallet.bifold") {
                Text("Billing view - Shows Unbilled hours, Billed hours, more?")
            }
        }
    }
}

#Preview {
    let project = Project(name: "Project", client: Client(name: "Client"))
    let navigationContext = NavigationContext()
    ProjectDetailView(project: project)
        .environment(navigationContext)
        .onAppear {
            navigationContext.selectedProject = project
        }
}

#Preview {
    ProjectTabView(
        project: Project(name: "Project", client: Client(name: "Client"))
    )
    .environment(NavigationContext())
}

#Preview {
    ProjectDetailContentView(
        project: Project(name: "Project", client: Client(name: "Client"))
    )
    .environment(NavigationContext())
}
