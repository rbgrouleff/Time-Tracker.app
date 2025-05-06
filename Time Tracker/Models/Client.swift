//
//  Client.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 30/01/2025.
//

import Foundation
import SwiftData

@Model
final class Client {
    @Attribute(.unique)
    var name: String

    @Relationship(deleteRule: .cascade, inverse: \Project.client)
    var projects = [Project]()

    init(name: String) {
        self.name = name
    }
    
    static func isNameAvailable(name: String, modelContext: ModelContext) -> Bool {
        let descriptor = FetchDescriptor<Client>(predicate: #Predicate { $0.name == name })
        return if let clientCount = try? modelContext.fetchCount(descriptor) {
            clientCount == 0
        } else {
            false
        }
    }
}
