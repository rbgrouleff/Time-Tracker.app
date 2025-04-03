//
//  TimingContext.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 28/03/2025.
//

import SwiftUI

@Observable
final class Time {
    var tick = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
}
