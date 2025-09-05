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
        var dict: [String : Any] = [:]
        dict["name"] = name
        dict["comment"] = comment
        dict["description"] = desc
        dict["elevation"] = elevation
        dict["source"] = source
        dict["symbol"] = symbol
        links.enumerated().forEach { i, link in
            dict["link\(i)"] = link.href
        }
        return .init(dict: dict)
    }
}
