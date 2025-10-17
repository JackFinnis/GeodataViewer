//
//  GPXRoute.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import Foundation
import CoreGPX
import CoreLocation

extension GPXRoute {
    var properties: Properties {
        var properties: Properties = [:]
        properties["name"] = name
        properties["comment"] = comment
        properties["description"] = desc
        properties["source"] = source
        properties["number"] = number
        links.enumerated().forEach { i, link in
            properties["link\(i)"] = link.href
        }
        return properties
    }
}
