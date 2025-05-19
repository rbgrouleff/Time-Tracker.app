//
//  TimingSessionEditorButtonView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 14/05/2025.
//

import SwiftUI

struct TimingSessionEditorButtonView: View {
    @Environment(NavigationContext.self) private var navigationContext

    var body: some View {
        Button("Add timing session") {
            navigationContext.isTimingSessionEditorPresented = true
        }
        .keyboardShortcut("t")
        .disabled(navigationContext.selectedProject == nil)
    }
}

#Preview {
    TimingSessionEditorButtonView()
        .environment(NavigationContext())
}
