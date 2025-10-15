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
        var dict: [String : Any] = [:]
        dict["name"] = name
        dict["comment"] = comment
        dict["description"] = desc
        dict["source"] = source
        dict["number"] = number
        links.enumerated().forEach { i, link in
            dict["link\(i)"] = link.href
        }
        return .init(dict: dict)
    }
}
