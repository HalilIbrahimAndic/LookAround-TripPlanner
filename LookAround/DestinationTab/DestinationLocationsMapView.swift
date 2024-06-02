//
//  DestinationLocationsMapView.swift
//  LookAround
//
//  Created by handic on 26.05.2024.
//

import SwiftUI
import MapKit

struct DestinationLocationsMapView: View {
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition)
            .onAppear {
                let coordinate = CLLocationCoordinate2D(latitude: 48.856788,
                                                   longitude: 2.351077)
                let span = MKCoordinateSpan(latitudeDelta: 0.15,
                                            longitudeDelta: 0.15)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                cameraPosition = .region(region)
        }
    }
}

#Preview {
    DestinationLocationsMapView()
}
