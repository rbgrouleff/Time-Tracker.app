//
//  AboutView.swift
//  Time Tracker
//
//  Created by Rasmus Bang Grouleff on 10/06/2025.
//

import SwiftUI

struct AboutView: View {
    private var appVersionAndBuild: String {
            let version = Bundle.main
                .infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
            let build = Bundle.main
                .infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
            return "Version \(version) (\(build))"
        }
        
        private var copyright: String {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: Date())
            return "© \(year) Rasmus Bang Grouleff"
        }
        
        private var developerWebsite: URL {
            URL(string: "https://nerdd.dk/")!
        }
        
        var body: some View {
            VStack(spacing: 14) {
                Image(.icon)
                    .resizable().scaledToFit()
                    .frame(width: 80)
                Text("Time Tracker")
                    .font(.title)
                VStack(spacing: 6) {
                    Text(appVersionAndBuild)
                    Text(copyright)
                }
                .font(.callout)
                Link(
                    "nerdd.dk",
                    destination: developerWebsite
                )
                .foregroundStyle(.blue)
            }
            .padding()
            .frame(minWidth: 400, minHeight: 260)
        }
}

#Preview {
    AboutView()
}
