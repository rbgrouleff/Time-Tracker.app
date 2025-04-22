//
//  InvoiceTests.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 18/04/2025.
//

import Foundation
import SwiftData
import Testing

@testable import Time_Tracker

@Suite("Invoice tests") struct InvoiceTests {
    var project: Project
    
    init() {
        self.project = Project(
            name: "Test Project",
            client: Client(name: "Test client")
        )
    }
    
    @Test func getFirstInvoiceNumber() async throws {
        let context = try getContext()
        #expect(
            Invoice.nextNumber(modelContext: context, date: .now) == .success(1)
        )
    }
    
    @Test func getAnotherInvoiceNumber() async throws {
        let context = try getContext()
        let invoice = Invoice(project, time: 100, date: .now, due: .now, number: 1)
        context.insert(invoice)
        #expect(
            Invoice.nextNumber(modelContext: context, date: .now) == .success(2)
        )
    }
    
    @Test func getInvoiceNumberWhenInsertionIsNotChronological() async throws {
        let context = try getContext()
        context.insert(Invoice(project, time: 100, date: .now, due: .now, number: 3))
        context.insert(Invoice(project, time: 100, date: .now, due: .now, number: 1))
        context.insert(Invoice(project, time: 100, date: .now, due: .now, number: 4))
        context.insert(Invoice(project, time: 100, date: .now, due: .now, number: 2))
        #expect(
            Invoice.nextNumber(modelContext: context, date: .now) == .success(5)
        )
    }
    
    @Test func getAnInvoiceNumberInANewYear() async throws {
        let context = try getContext()
        let invoice = Invoice(project, time: 100, date: dateAt(year: 2024, month: 10, day: 20, hour: 20, minute: 10, second: 10), due: .now, number: 1)
        context.insert(invoice)
        #expect(
            Invoice.nextNumber(modelContext: context, date: dateAt(year: 2025, month: 10, day: 20, hour: 20, minute: 10, second: 10)) == .success(1)
        )
    }
    
    private func getContext() throws -> ModelContext {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: Invoice.self,
            configurations: config
        )
        return ModelContext(container)
    }
    
    private func dateAt(year: Int, month: Int, day: Int, hour: Int, minute: Int, second: Int) -> Date {
        let components = DateComponents(timeZone: TimeZone(abbreviation: "UTC"),year: year, month: month, day: day, hour: hour, minute: minute, second: second)
        return Calendar(identifier: .gregorian).date(from: components)!
    }
}
