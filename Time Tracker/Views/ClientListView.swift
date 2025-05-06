//
//  ClientListView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 21/02/2025.
//

import SwiftUI
import SwiftData

struct ClientListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(NavigationContext.self) private var navigationContext: NavigationContext
    @Query(sort: \Client.name) private var clients: [Client]
    @State private var isEditorPresented = false
    
    var body: some View {
        @Bindable var navigationContext = navigationContext
        List(selection: $navigationContext.selectedClient) {
            Section("Clients") {
                ClientList(clients: clients)
            }
        }
        .sheet(isPresented: $isEditorPresented) {
            ClientEditor(client: nil)
        }
        .overlay {
            if clients.isEmpty {
                ContentUnavailableView {
                    Label("No clients yet!", systemImage: "person.crop.square")
                } description: {
                    AddClientButton(isActive: $isEditorPresented)
                }
            }
        }
        .toolbar {
            AddClientButton(isActive: $isEditorPresented)
            DeleteClientButton(client: $navigationContext.selectedClient)
        }
        .onChange(of: navigationContext.selectedClient) {
            navigationContext.selectedProject = nil
        }
    }
}

private struct ClientList: View {
    var clients: [Client]
    
    var body: some View {
        ForEach(clients) { client in
            NavigationLink(client.name, value: client)
        }
    }
}

private struct AddClientButton: View {
    @Binding var isActive: Bool
    
    var body: some View {
        Button {
            isActive = true
        } label: {
            Label("Add a new client", systemImage: "plus")
                .help("Add a new client")
        }
    }
}

private struct DeleteClientButton: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var client: Client?
    
    var body: some View {
        Button("Delete the client", systemImage: "trash", role: .destructive) {
            if let client {
                deleteClient(client)
            }
        }
        .help("Delete the client")
        .disabled($client.wrappedValue == nil)
    }
    
    private func deleteClient(_ client: Client) {
        self.client = nil
        modelContext.delete(client)
    }
}
