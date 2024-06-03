//
//  LookAroundApp.swift
//  LookAround
//
//  Created by handic on 26.05.2024.
//

import SwiftUI
import SwiftData

@main
struct LookAroundApp: App {
    var body: some Scene {
        WindowGroup {
            StartTab()
        }
        .modelContainer(for: Destination.self)
    }
}
