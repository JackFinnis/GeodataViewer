//
//  GMUPlacemark.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import GoogleMapsUtils

extension GMUPlacemark {
    var properties: Properties {
        var dict: [String : Any] = [:]
        dict["title"] = title
        dict["snippet"] = snippet
        return .init(dict: dict)
    }
}
