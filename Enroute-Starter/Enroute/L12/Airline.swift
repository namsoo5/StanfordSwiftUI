//
//  Airline.swift
//  Enroute
//
//  Created by 남수김 on 2021/04/01.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import Combine
import CoreData

extension Airline: Comparable {
    static func withCode(_ code: String, in context: NSManagedObjectContext) -> Airline {
        let request = fetchRequest(NSPredicate(format: "code_ = %@", code))
        let results = (try? context.fetch(request)) ?? []
        if let airline = results.first {
            return airline
        } else {
            let airline = Airline(context: context)
            airline.code = code
            AirlineInfoRequest.fetch(code) { info in
                let airline = self.withCode(code, in: context)
                airline.name = info.name
                airline.shortname = info.shortname
                airline.objectWillChange.send()
                airline.flights.forEach { $0.objectWillChange.send() }
                try? context.save()
            }
            return airline
        }
    }

    var code: String {
        get { code_! } // TODO: maybe protect against when app ships?
        set { code_ = newValue }
    }
    var name: String {
        get { name_ ?? code }
        set { name_ = newValue }
    }
    var shortname: String {
        get { (shortname_ ?? "").isEmpty ? name : shortname_! }
        set { shortname_ = newValue }
    }
    var flights: Set<Flight> {
        get { (flights_ as? Set<Flight>) ?? [] }
        set { flights_ = newValue as NSSet }
    }
    var friendlyName: String { shortname.isEmpty ? name : shortname }

    public var id: String { code }

    public static func < (lhs: Airline, rhs: Airline) -> Bool {
        lhs.name < rhs.name
    }
}

// MARK: - Core Data

extension Airline {
    static func fetchRequest(_ predicate: NSPredicate) -> NSFetchRequest<Airline> {
        let request = NSFetchRequest<Airline>(entityName: "Airline")
        request.sortDescriptors = [NSSortDescriptor(key: "name_", ascending: true)]
        request.predicate = predicate
        return request
    }
}
