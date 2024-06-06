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
    // SwiftData'da destination'ı olmayan tüm placemarkları getir
    @Query(filter: #Predicate<LAPlacemark> {$0.destination == nil}) private var searchPlacemarks: [LAPlacemark]
    
    // All placemarks
    private var listPlacemarks: [LAPlacemark] {
        searchPlacemarks + destination.placemarks
    }
    // Incoming destination (e.g. Rome, İstanbul)
    var destination: Destination
    
    @State private var selectedPlacemark: LAPlacemark?
    var body: some View {
        @Bindable var destination = destination

        // MARK: - Map
        Map(position: $cameraPosition, selection: $selectedPlacemark) {
            ForEach(listPlacemarks) { placemark in
                Group {
                    if placemark.destination != nil {
                        Marker(coordinate: placemark.coordinate) {
                            Label(placemark.name, systemImage: "star")
                        }
                        .tint(.yellow)
                    } else {
                        Marker(placemark.name, coordinate: placemark.coordinate)
                    }
                }.tag(placemark)
            }
        }
        // Bottom Sheet
        .sheet(item: $selectedPlacemark, content: { selectedPlacemark in
            Text(selectedPlacemark.name)
                .presentationDetents([.height(450)])
        })
        // Search
        .safeAreaInset(edge: .top,
                       content: {
            HStack {
                TextField("Search...", text: $searchText)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
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
                            cameraPosition = .automatic
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
        // Set region
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
