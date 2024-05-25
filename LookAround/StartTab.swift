//
//  ContentView.swift
//  LookAround
//
//  Created by handic on 26.05.2024.
//

import SwiftUI

struct StartTab: View {
    
    var body: some View {
        TabView {
            Group {
                TripMapView()
                    .tabItem {
                        Label("Map", systemImage: "map")
                    }
                DestinationLocationsMapView()
                    .tabItem {
                        Label("Destinations", systemImage: "globe.desk")
                    }
            }
            .toolbarBackground(.blue.opacity(0.8), for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .toolbarColorScheme(.dark, for: .tabBar)
        }
    }
}

#Preview {
    StartTab()
}
