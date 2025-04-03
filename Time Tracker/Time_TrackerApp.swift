//
//  Time_TrackerApp.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 29/01/2025.
//

import SwiftUI
import SwiftData

@main
struct Time_TrackerApp: App {
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Client.self,
            Project.self,
            Interval.self,
            WorkPeriod.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
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
        }
#endif
    }
}
