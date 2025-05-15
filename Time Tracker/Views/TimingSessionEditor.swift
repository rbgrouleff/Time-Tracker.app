//
//  AddTimingSessionButton.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 09/05/2025.
//

import SwiftUI

struct TimingSessionEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State var project: Project

    @State private var editorTitle = "Add manual timing session"

    @State private var startedAt: Date = .now
    @State private var hours: Int = 0
    @State private var minutes: Int = 0

    var body: some View {
        Form {
            HStack {
                LabeledContent("Duration:") {
                    TextField(
                        "Hours:",
                        value: $hours,
                        formatter: NumberFormatter()
                    ).labelsHidden()
                    Stepper(
                        "Hours:",
                        onIncrement: { hours += 1 },
                        onDecrement: {
                            if hours > 0 {
                                hours -= 1
                            }
                        }
                    ).labelsHidden()
                    TextField(
                        "Hours:",
                        value: $minutes,
                        formatter: NumberFormatter()
                    ).labelsHidden()
                    Stepper(
                        "Hours:",
                        onIncrement: {
                            if minutes < 59 {
                                minutes += 1
                            } else {
                                minutes = 0
                                hours += 1
                            }
                        },
                        onDecrement: {
                            if minutes > 0 {
                                minutes -= 1
                            } else if hours > 0 {
                                hours -= 1
                                minutes = 59
                            }
                        }
                    ).labelsHidden()
                }
            }

            DatePicker(
                "Started at:",
                selection: $startedAt,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.compact)
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
                .disabled(hours == 0 && minutes == 0)
            }

            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", role: .cancel) {
                    withAnimation {
                        dismiss()
                    }
                }
            }
        }
        .padding()
    }

    private func save() {
        if hours > 0 || minutes > 0 {
            let timingSession = TimingSession(
                project: project,
                startedAt: startedAt,
                stoppedAt: startedAt + TimeInterval(hours * 3600 + minutes * 60)
            )
            project.timingSessions.append(timingSession)
            modelContext.insert(timingSession)
        }
    }
}

#Preview {
    let project = Project(
        name: "Test Project",
        client: Client(name: "Test Client")
    )
    TimingSessionEditor(project: project)
}
