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
    @State private var visibleRegion: MKCoordinateRegion?
    
    var body: some View {
        Map(position: $cameraPosition) {
            Marker("Moulin Rouge", coordinate: .moulinRouge)
            
            Marker(coordinate: .arcDeTriomphe) {
                Label("Arc de Triomphe", systemImage: "star.fill")
            }
            .tint(.yellow)
            
            Marker("Gare du Nord", monogram: Text("GN"), coordinate: .gareDuNord)
                .tint(.orange)
            
            Marker("Louvre", systemImage: "person.crop.artframe", coordinate: .louvre)
                .tint(.main)
            
            Annotation("Notre Dame", coordinate: .notreDame) {
                Image(systemName: "star")
                    .imageScale(.large)
                    .foregroundStyle(.red)
                    .padding(10)
                    .background(.white)
                    .clipShape(.circle)
            }
            
            Annotation("Sacre Coeur", coordinate: .sacreCoeur, anchor: .center) {
                Image(.sacre)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            }
            
            Annotation("Pantheon", coordinate: .pantheon) {
                Image(systemName: "mappin")
                    .imageScale(.large)
                    .foregroundStyle(.red)
                    .padding(5)
                    .overlay {
                        Circle()
                            .strokeBorder(.red, lineWidth: 2)
                    }
            }
            
            MapCircle(center: CLLocationCoordinate2D(
                latitude: 48.856788,
                longitude: 2.351077),
                      radius: 5000)
            .foregroundStyle(.red.opacity(0.5))
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
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
