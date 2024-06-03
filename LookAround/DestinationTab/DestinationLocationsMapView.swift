//
//  DestinationLocationsMapView.swift
//  LookAround
//
//  Created by handic on 26.05.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct DestinationLocationsMapView: View {
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @Query private var destinations: [Destination]
    @State private var destination: Destination?
    
    var body: some View {
        Map(position: $cameraPosition) {
            if let destination {
                ForEach(destination.placemarks) { placemark in
                    Marker(coordinate: placemark.coordinate) {
                        Label(placemark.name, systemImage: "star")
                    }
                    .tint(.yellow)
                }
            }
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
        .onAppear {
            destination = destinations.first
            if let region = destination?.region {
                cameraPosition = .region(region)
            }
        }
    }
}

#Preview {
    DestinationLocationsMapView()
        .modelContainer(Destination.preview)
}
