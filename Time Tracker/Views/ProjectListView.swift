//
//  ProjectListView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 20/02/2025.
//

import SwiftUI
import SwiftData

struct ProjectListView: View {
    let client: Client?

    var body: some View {
        if let client {
            ProjectList(client: client)
        } else {
            ContentUnavailableView("Select a client", systemImage: "person.crop.square")
        }
    }
}

private struct ProjectList: View {
    private let client: Client
    @Environment(NavigationContext.self) private var navigationContext: NavigationContext
    @Environment(\.modelContext) private var modelContext
    @Query private var projects: [Project]
    @State private var isEditorPresented = false
    
    init(client: Client) {
        self.client = client
        let clientName = client.name
        let predicate = #Predicate<Project> { project in
            project.client?.name == clientName
        }
        _projects = Query(filter: predicate)
    }

    var body: some View {
        @Bindable var navigationContext = navigationContext
        List(selection: $navigationContext.selectedProject) {
            ForEach(projects) { project in
                NavigationLink(project.name, value: project)
            }
        }
        .sheet(isPresented: $isEditorPresented) {
            ProjectEditor(project: nil, selectedClient: client)
        }
        .overlay {
            if projects.isEmpty {
                ContentUnavailableView {
                    Label("No projects yet", systemImage: "calendar.badge.clock")
                } description: {
                    AddProjectButton(isActive: $isEditorPresented)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddProjectButton(isActive: $isEditorPresented)
            }
        }
    }
}

private struct AddProjectButton: View {
    @Binding var isActive: Bool
    
    var body: some View {
        Button {
            isActive = true
        } label: {
            Label("Add new project", systemImage: "calendar.badge.plus")
        }
    }
}

#Preview {
    AddProjectButton(isActive: .constant(false))
        .environment(NavigationContext())
        .modelContainer(for: Client.self, inMemory: true)
}
