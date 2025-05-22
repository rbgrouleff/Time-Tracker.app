//
//  InvoiceTableView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 05/05/2025.
//

import SwiftUI

struct InvoiceTableView: View {
    @Binding var invoices: [Invoice]
    @State var filterBy: KeyPath<Invoice, Bool>?
    @State private var selectedInvoiceID: Invoice.ID?

    var body: some View {
        let invoices = if let filterBy {
            invoices.filter { $0[keyPath: filterBy] }
        } else {
            invoices
        }
        Table(invoices, selection: $selectedInvoiceID) {
            TableColumn("#") { invoice in
                Text("\(invoice.number)")
            }

            TableColumn("Created") { invoice in
                Text(invoice.date, format: .dateTime.day().month().year())
            }

            TableColumn("Due") { invoice in
                Text(invoice.due, format: .dateTime.day().month().year())
                    .background(invoice.isOverdue ? .red : .clear)
            }

            TableColumn("Invoiced time") { invoice in
                Text(
                    invoice.duration,
                    format: .units(allowed: [.hours], width: .wide)
                )
            }

            TableColumn("Paid") { invoice in
                Toggle(
                    "Paid",
                    isOn: $invoices[
                        self.invoices.firstIndex(where: { $0 == invoice })!
                    ].isPaid
                )
                .labelsHidden()
                .toggleStyle(.checkbox)
            }
        }
        .contextMenu(forSelectionType: Invoice.ID.self) { items in
            if items.count == 1 {
                if let invoice = invoices.first(where: {
                    $0.id == items.first!
                }) {
                    Button("Mark unpaid") {
                        withAnimation {
                            markUnpaid(invoice: invoice)
                        }
                    }
                    .disabled(!invoice.isPaid)
                }
            }
        }
    }

    private func markUnpaid(invoice: Invoice) {
        invoice.paidAt = nil
    }
}

#Preview {
    @Previewable @State var project = Project(
        name: "Test Project",
        client: Client(name: "Test Client")
    )
    InvoiceTableView(invoices: $project.invoices, filterBy: \.isPaid)
        .onAppear {
            project.timingSessions.append(
                TimingSession(
                    project: project,
                    startedAt: .now - 7200,
                    stoppedAt: .now
                )
            )
            _ = project.createInvoice(
                time: 7200,
                date: .now,
                due: .now,
                number: 1
            )
        }
}
