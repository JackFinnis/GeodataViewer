//
//  GMUPlacemark.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import GoogleMapsUtils

extension GMUPlacemark {
    var properties: Properties {
        var properties: Properties = [:]
        properties["title"] = title
        properties["snippet"] = snippet
        return properties
    }
}
