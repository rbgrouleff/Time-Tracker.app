//
//  Time_TrackerApp.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 29/01/2025.
//

import SwiftData
import SwiftUI

@main
struct Time_TrackerApp: App {
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Client.self,
            Project.self,
            TimingSession.self,
            Invoice.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var navigationContext = NavigationContext()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationContext)
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
            .commands {
                SidebarCommands()
                
                CommandMenu("Project") {
                    TimingSessionButtonView().environment(navigationContext)
                    TimingSessionEditorButtonView().environment(navigationContext)
                }
            }
        #endif
    }
}
