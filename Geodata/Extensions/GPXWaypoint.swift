//
//  GPX.swift
//  Geojson
//
//  Created by Jack Finnis on 11/05/2023.
//

import Foundation
import CoreGPX
import CoreLocation

extension GPXWaypoint {
    var coord: CLLocationCoordinate2D? {
        guard let latitude, let longitude else { return nil }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var properties: Properties {
        var properties: Properties = [:]
        properties["name"] = name
        properties["comment"] = comment
        properties["description"] = desc
        properties["elevation"] = elevation
        properties["source"] = source
        properties["symbol"] = symbol
        links.enumerated().forEach { i, link in
            properties["link\(i)"] = link.href
        }
        return properties
    }
}
