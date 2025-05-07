//
//  ClientEditor.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 27/02/2025.
//

import SwiftUI
import SwiftData

struct ClientEditor: View {
    let client: Client?
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    
    private var editorTitle: String {
        client == nil ? "Add client" : "Edit client"
    }
    
    var body: some View {
        NavigationStack {
            Form {
                VStack {
                    TextField("Name", text: $name).padding(.all)
                    if !Client.isNameAvailable(name: name, modelContext: modelContext) {
                        Text("Name is taken")
                            .fontWeight(.light)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
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
                    .disabled($name.wrappedValue == "" || !Client.isNameAvailable(name: name, modelContext: modelContext))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .padding()
        }
    }
    
    private func save() {
        if let client {
            if Client.isNameAvailable(name: name, modelContext: modelContext) {
                client.name = name
            }
        } else {
            if Client.isNameAvailable(name: name, modelContext: modelContext) {
                let newClient = Client(name: name)
                modelContext.insert(newClient)
            }
        }
    }
}

#Preview {
    ClientEditor(client: nil)
        .modelContainer(for: Client.self, inMemory: true)
}
