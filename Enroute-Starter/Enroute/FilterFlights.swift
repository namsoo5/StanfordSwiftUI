//
//  FilterFlights.swift
//  Enroute
//
//  Created by 남수김 on 2021/03/23.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

struct FilterFlights: View {
    @FetchRequest(fetchRequest: Airport.fetchRequest(.all)) var airports: FetchedResults<Airport>
    @FetchRequest(fetchRequest: Airline.fetchRequest(.all)) var airlines: FetchedResults<Airline>
    
    @Binding var flightSearch: FlightSearch
    @Binding var isPresented: Bool
    
    @State private var draft: FlightSearch
    
    init(flightSearch: Binding<FlightSearch>, isPresented: Binding<Bool>) {
        _flightSearch = flightSearch
        _isPresented = isPresented
        _draft = State(wrappedValue: flightSearch.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // selection과 tag의 타입이 일치해야함
                Picker("Destination", selection: $draft.destination) {
                    ForEach(airports.sorted(), id: \.self) { airport in
                        Text("\(airport.friendlyName)").tag(airport)
                    }
                }
                Picker("Origin", selection: $draft.origin) {
                    Text("Any").tag(Airport?.none)
                    ForEach(airports.sorted(), id: \.self) { (airport: Airport?) in
                        Text("\(airport?.friendlyName ?? "Any")").tag(airport)
                    }
                }
                Picker("Airline", selection: $draft.airline) {
                    Text("Any").tag(String?.none)
                    ForEach(airlines.sorted(), id: \.self) { (airline: Airline?) in
                        Text("\(airline?.friendlyName ?? "Any")").tag(airline)
                    }
                }
                Toggle(isOn: $draft.inTheAir) {
                    Text("Enroute Only")
                }
            }
            .navigationBarTitle("Filter Flights")
            .navigationBarItems(leading: cancel, trailing: done)
        }
        
    }
    
    var cancel: some View {
        Button("Cancel") {
            isPresented = false
        }
    }
    
    var done: some View {
        Button("Done") {
            if self.draft.destination != self.flightSearch.destination {
                self.draft.destination.fetchIncomingFlights()
            }
            flightSearch = draft
            isPresented = false
        }
    }
}
