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
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    DestinationListView()
        .modelContainer(Destination.preview)
}
