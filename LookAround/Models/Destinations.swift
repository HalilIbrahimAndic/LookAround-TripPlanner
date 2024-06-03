//
//  Destinations.swift
//  LookAround
//
//  Created by handic on 3.06.2024.
//

import SwiftData
import MapKit

@Model
class Destinations {
    var name: String
    var latitude: Double?
    var longitude: Double?
    var latitudeDelta: Double?
    var longitudeDelta: Double?
    
    init(name: String, latitude: Double? = nil, longitude: Double? = nil, latitudeDelta: Double? = nil, longitudeDelta: Double? = nil) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.latitudeDelta = latitudeDelta
        self.longitudeDelta = longitudeDelta
    }
    
    var region: MKCoordinateRegion? {
        if let latitude, let longitude, let latitudeDelta, let longitudeDelta {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
            )
        } else {
            return nil
        }
    }
}
