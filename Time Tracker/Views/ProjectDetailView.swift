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

            HStack {
                VStack(alignment: .leading) {
                    Text("Unbilled time").font(.headline)
                    
                    Text(
                        project.unbilledDuration,
                        format: .units(
                            allowed: [.hours, .minutes],
                            width: .narrow,
                            zeroValueUnits: .show(length: 2)
                        )
                    )
                }
                
                Spacer()
                
                VStack {
                    Button {
                    } label: {
                        Text("Create invoice")
                    }
                }
            }
            .padding()

            ProjectTabView(project: project)
        }
    }
}

private struct ProjectTabView: View {
    var project: Project

    var body: some View {
        TabView {
            Tab("Unbilled sessions", systemImage: "timer") {
                TimingSessionTableView(timingSessions: project.unbilledTimingSessions)
            }
            Tab("Invoices", systemImage: "wallet.bifold") {
                Text("Invoices")
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
