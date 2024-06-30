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
    
    @State private var isManualMarker = false
    @State private var selectedPlacemark: LAPlacemark?
    var body: some View {
        @Bindable var destination = destination
        
        // MARK: - Map
        MapReader { proxy in
            Map(position: $cameraPosition, selection: $selectedPlacemark) {
                ForEach(listPlacemarks) { placemark in
                    if isManualMarker {
                        Group {
                            if placemark.destination != nil {
                                Marker(coordinate: placemark.coordinate) {
                                    Label(placemark.name, systemImage: "pin")
                                }
                                .tint(.main)
                            } else {
                                Marker(placemark.name, coordinate: placemark.coordinate)
                            }
                        }
                    } else {
                        Group {
                            if placemark.destination != nil {
                                Marker(coordinate: placemark.coordinate) {
                                    Label(placemark.name, systemImage: "pin")
                                }
                                .tint(.main)
                            } else {
                                Marker(placemark.name, coordinate: placemark.coordinate)
                            }
                        }.tag(placemark)
                    }
                    
                }
            }
            .mapStyle(.standard(elevation: .realistic))
//            .mapControls {
//                MapPitchToggle()
//                MapCompass()
//            }
            // New Placemark
            .onTapGesture { position in
                if isManualMarker {
                    if let coordinate = proxy.convert(position, from: .local) {
                        let newPlacemark = LAPlacemark(
                            name: "",
                            address: "",
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        )
                        modelContext.insert(newPlacemark)
                        selectedPlacemark = newPlacemark
                    }
                }
            }
        }
        // Bottom Sheet
        .sheet(item: $selectedPlacemark,
               onDismiss: {
            if isManualMarker {
                MapManager.removeSearchResults(modelContext)
            }
        }, content: { selectedPlacemark in
            LocationDetailView(
                destination: destination,
                selectedPlacemark: selectedPlacemark
            )
            .presentationDetents([.height(450)])
        })
        // Search
        .safeAreaInset(edge: .top,
                       content: {
            VStack {
                if !isManualMarker {
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
                }
                
                HStack {
                    Spacer()
                    Toggle(isOn: $isManualMarker) {
                        Image(systemName: isManualMarker ? "mappin.circle" : "mappin.slash.circle")
                            .tint(isManualMarker ? .red : .gray)
                            .imageScale(.large)
                    }
                    .toggleStyle(.button)
                    .background(in: Circle())
                    .padding(EdgeInsets(top: 12, leading: 0, bottom: 0, trailing: 16))
                    .onChange(of: isManualMarker) {
                        MapManager.removeSearchResults(modelContext)
                    }
                }
            }
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
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 12, trailing: 24))
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
