//
//  ClientEditor.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 27/02/2025.
//

import SwiftUI

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
                TextField("Name", text: $name)
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
                    .disabled($name.wrappedValue == "")
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
            client.name = name
        } else {
            let newClient = Client(name: name)
            modelContext.insert(newClient)
        }
    }
}

#Preview {
    ClientEditor(client: nil)
}
