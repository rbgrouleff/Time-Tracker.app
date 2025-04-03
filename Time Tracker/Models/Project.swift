//
//  Project.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 30/01/2025.
//

import Foundation
import SwiftData

@Model
final class Project {
    var name: String
    var client: Client
    
    @Relationship(deleteRule: .cascade, inverse: \TimingSession.project)
    var timingSessions = [TimingSession]()
    
    init(name: String, client: Client) {
        self.name = name
        self.client = client
    }
}
