//
//  ProjectEditor.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 06/03/2025.
//

import SwiftUI
import SwiftData

struct ProjectEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var clients: [Client]
    let project: Project?
    
    @State var selectedClient: Client?
    @State private var name = ""
    
    private var editorTitle: String {
        project == nil ? "Add project" : "Edit project"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)
                
                Picker("Client", selection: $selectedClient) {
                    Text("Select a client").tag(nil as Client?)
                    ForEach(clients) { client in
                        Text(client.name).tag(client as Client?)
                    }
                }
                .disabled(project != nil)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }
                    .disabled($selectedClient.wrappedValue == nil || $name.wrappedValue.isEmpty)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let project {
                    name = project.name
                    selectedClient = project.client
                }
            }
            .padding()
        }
    }
    
    private func save() {
        if let project {
            project.name = name
        } else {
            let newProject = Project(name: name, client: selectedClient!)
            modelContext.insert(newProject)
        }
    }
}

#Preview {
    ProjectEditor(project: nil, selectedClient: Client(name: "Test"))
        .modelContainer(for: Client.self, inMemory: true)
}
