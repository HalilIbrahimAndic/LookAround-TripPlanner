//
//  LocationDetailView.swift
//  LookAround
//
//  Created by handic on 6.06.2024.
//

import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var destination: Destination?
    var selectedPlacemark: LAPlacemark?
    
    @State private var name = ""
    @State private var address = ""
    
    var isChanged: Bool {
        guard let selectedPlacemark else { return false }
        return (name != selectedPlacemark.name || address != selectedPlacemark.address)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, content: {
                    TextField("Name", text: $name)
                        .font(.title)
                    TextField("Name", text: $address, axis: .vertical)
                })
                .textFieldStyle(.roundedBorder)
                if isChanged {
                    Button("Update") {
                        selectedPlacemark?.name = name
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                        selectedPlacemark?.address = address
                            .trimmingCharacters(in: .whitespacesAndNewlines)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .buttonStyle(.borderedProminent)
                }
                Spacer()
                Button(action: {
                    dismiss()
                }, label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.gray)
                })
            }
            
            HStack {
                Spacer()
                if let destination {
                    let inList = (selectedPlacemark != nil && selectedPlacemark?.destination != nil)
                    Button(action: {
                        if let selectedPlacemark {
                            if selectedPlacemark.destination == nil {
                                destination.placemarks.append(selectedPlacemark)
                            } else {
                                selectedPlacemark.destination = nil
                            }
                            dismiss()
                        }
                    }, label: {
                        Label(inList ? "Remove" : "Add", systemImage: inList ? "minus.circle" : "plus.circle")
                    })
                    .buttonStyle(.borderedProminent)
                    .tint(inList ? .red : .green)
                    .disabled((name.isEmpty || isChanged))
                }
            }
            
            Spacer()
        }
        .padding()
            .onAppear {
                if let selectedPlacemark, destination != nil {
                    name = selectedPlacemark.name
                    address = selectedPlacemark.address
                }
            }
    }
}

#Preview {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    let selectedPlacemark = destination.placemarks[0]
    return LocationDetailView(destination: destination, selectedPlacemark: selectedPlacemark)
}
