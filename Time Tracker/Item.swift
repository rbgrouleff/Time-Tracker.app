//
//  Item.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 29/01/2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
