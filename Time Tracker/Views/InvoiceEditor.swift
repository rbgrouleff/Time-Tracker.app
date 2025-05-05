//
//  InvoiceEditor.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 14/04/2025.
//

import SwiftUI

struct InvoiceEditor: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State var project: Project
    @State private var hours = 0
    @State private var due = Date.now
    
    @State private var editorTitle = "Create invoice"

    var unbilledHours: ClosedRange<Int> {
        0...Int(project.unbilledDuration.components.seconds / 3600)
    }

    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading) {
                        LabeledContent {
                            switch Invoice.nextNumber(modelContext: modelContext, date: .now) {
                            case .success(let n):
                                Text("\(n)")
                            case .failure(_):
                                Label("Could not obtain number", systemImage: "questionmark.circle.fill")
                                    .foregroundStyle(.primary, .red)
                            }
                        } label: {
                            Text("Invoice Number:")
                        }
                    
                    LabeledContent {
                        Stepper("\(hours)", value: $hours, in: unbilledHours, step: 1)
                    } label: {
                        Text("Hours to bill:")
                    }

                    DatePicker("Due date:", selection: $due, displayedComponents: [.date])
                        .datePickerStyle(.compact)
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
                    .disabled(project.unbilledDuration == .zero || hours == 0)
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
    }
    
    private func save() {
        _ = Invoice.nextNumber(modelContext: modelContext, date: .now)
            .flatMap { n in
                project.createInvoice(time: TimeInterval(hours * 3600), date: .now, due: due, number: n)
                    .mapError { _ in Invoice.Error.createFailed }
            }
    }
}

#Preview {
    let project = Project(name: "Test project", client: Client(name: "Test Client"))
    InvoiceEditor(project: project)
        .onAppear {
            project.timingSessions.append(TimingSession(project: project, startedAt: Date.init(timeInterval: -36000, since: .now), stoppedAt: .now))
        }
}
