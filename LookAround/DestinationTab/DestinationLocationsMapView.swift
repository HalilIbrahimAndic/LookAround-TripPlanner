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
    @Environment(\.modelContext) private var modelContext
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText = ""
    @FocusState private var searchFieldFocus: Bool
    @Query(filter: #Predicate<LOPlacemark> {$0.destination == nil}) private var searchPlacemarks: [LOPlacemark]
    
    private var listPlacemarks: [LOPlacemark] {
        searchPlacemarks + destination.placemarks
    }
    var destination: Destination
    
    var body: some View {
        @Bindable var destination = destination

        Map(position: $cameraPosition) {
            ForEach(listPlacemarks) { placemark in
                if placemark.destination != nil {
                    Marker(coordinate: placemark.coordinate) {
                        Label(placemark.name, systemImage: "star")
                    }
                    .tint(.yellow)
                } else {
                    Marker(placemark.name, coordinate: placemark.coordinate)
                }
            }
        }
        .safeAreaInset(edge: .top,
                       content: {
            HStack {
                TextField("Search...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .focused($searchFieldFocus)
                    .overlay(alignment: .trailing) {
                        if searchFieldFocus {
                            Button {
                                searchText = ""
                                searchFieldFocus = false
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                            }
                            .offset(x: -5)
                        }
                    }
                    .onSubmit {
                        Task {
                            await MapManager.searchPlaces(modelContext,
                                                          searchText: searchText,
                                                          visibleRegion: visibleRegion)
                            searchText = ""
                        }
                    }
                
                if !searchPlacemarks.isEmpty {
                    Button(action: {
                        MapManager.removeSearchResults(modelContext)
                    }, label: {
                        Image(systemName: "mappin.slash.circle.fill")
                            .imageScale(.large)
                    })
                    .foregroundStyle(.white)
                    .padding(8)
                    .background(.red)
                    .clipShape(.circle)
                }
            }
            .padding()
        })
        .safeAreaInset(edge: .bottom, content: {
            HStack {
                LabeledContent {
                    TextField("Enter destination name", text: $destination.name)
                        .textFieldStyle(.roundedBorder)
                        .foregroundStyle(.primary)
                } label: {
                    Text("")
                }
                
                Button("Set region") {
                    if let visibleRegion {
                        destination.latitude = visibleRegion.center.latitude
                        destination.longitude = visibleRegion.center.longitude
                        destination.latitudeDelta = visibleRegion.span.latitudeDelta
                        destination.longitudeDelta = visibleRegion.span.longitudeDelta
                    }
                }
                .tint(.main)
                .buttonStyle(.borderedProminent)
            }
            .padding(EdgeInsets(top: 0, leading: 25, bottom: 10, trailing: 25))
        })
        .navigationTitle("Destination")
        .navigationBarTitleDisplayMode(.inline)
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
        .onAppear {
            MapManager.removeSearchResults(modelContext)
            if let region = destination.region {
                cameraPosition = .region(region)
            }
        }
        .onDisappear {
            MapManager.removeSearchResults(modelContext)
        }
    }
}

#Preview {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    return NavigationStack {
        DestinationLocationsMapView(destination: destination)
    }
    .modelContainer(Destination.preview)
}
