//
//  ProjectDetailsView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 27/02/2025.
//

import SwiftUI

struct ProjectDetailView: View {
    @Environment(NavigationContext.self) private var navigationContext
    var project: Project?
    @State private var isInvoiceEditorPresented = false
    @Binding var isTimingSessionEditorPresented: Bool

    var body: some View {
        @Bindable var navigationContext = navigationContext
        if let project {
            ProjectDetailContentView(
                project: project,
                isInvoiceEditorPresented: $isInvoiceEditorPresented
            )
            .navigationTitle("\(project.name)")
            .sheet(isPresented: $isInvoiceEditorPresented) {
                InvoiceEditor(project: project)
            }
            .sheet(isPresented: $isTimingSessionEditorPresented) {
                TimingSessionEditor(project: project)
            }
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
    @Binding var isInvoiceEditorPresented: Bool

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
                        format: .time(pattern: .hourMinuteSecond)
                    )
                }

                Spacer()

                VStack(alignment: .trailing) {
                    TimingSessionEditorButtonView()
                    Button {
                        isInvoiceEditorPresented = true
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
                TimingSessionTableView(
                    timingSessions: project.unbilledTimingSessions
                )
            }
            Tab("Invoices", systemImage: "wallet.bifold") {
                @Bindable var project = project
                InvoiceTableView(invoices: $project.invoices)
            }
        }
    }
}

#Preview {
    @Previewable @State var isTimingSessionEditorPresented = false
    let project = Project(name: "Project", client: Client(name: "Client"))
    let navigationContext = NavigationContext()
    ProjectDetailView(project: project, isTimingSessionEditorPresented: $isTimingSessionEditorPresented)
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
        project: Project(name: "Project", client: Client(name: "Client")),
        isInvoiceEditorPresented: .constant(false)
    )
    .environment(NavigationContext())
    .modelContainer(for: Client.self, inMemory: true)
}
