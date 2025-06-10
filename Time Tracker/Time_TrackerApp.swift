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
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(navigationContext)
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
            .commands {
                SidebarCommands()
                CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                    Button {
                        openWindow(id: "about")
                    } label: {
                        Text("About Time Tracker")
                    }
                }
                CommandMenu("Project") {
                    TimingSessionButtonView().environment(navigationContext)
                    TimingSessionEditorButtonView().environment(
                        navigationContext
                    )
                }
            }
        #endif

        Window("About Time Tracker", id: "about") {
            AboutView().containerBackground(.regularMaterial, for: .window)
                .toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
        }.windowBackgroundDragBehavior(.enabled).windowResizability(
            .contentSize
        ).restorationBehavior(.disabled)
    }
}
