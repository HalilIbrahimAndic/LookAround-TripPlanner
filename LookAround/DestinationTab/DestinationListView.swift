//
//  DestinationListView.swift
//  LookAround
//
//  Created by handic on 3.06.2024.
//

import SwiftUI
import SwiftData

struct DestinationListView: View {
    @Query(sort: \Destination.name) private var destinations: [Destination]
    var body: some View {
        NavigationStack {
            Group {
                if !destinations.isEmpty{
                    List(destinations) { destination in
                        HStack {
                            Image(systemName: "globe")
                                .imageScale(.large)
                                .foregroundStyle(.orange)
                            VStack(alignment: .leading) {
                                Text(destination.name)
                                Text("^[\(destination.placemarks.count) location](inflect: true)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "No Destinations",
                        systemImage: "globe.desk",
                        description: Text("You have not set up any destinations yet. Tap on the \(Image(systemName: "plus.circle.fill")) button in the toolbar to begin")
                    )
                }
            }
            .navigationTitle("My Destinations")
            .toolbar {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "plus.circle.fill")
                        .tint(.orange)
                })
            }
        }
    }
}

#Preview {
    DestinationListView()
        .modelContainer(Destination.preview)
}
