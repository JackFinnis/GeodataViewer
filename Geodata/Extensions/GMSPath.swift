//
//  GMUPath.swift
//  Geojson
//
//  Created by Jack Finnis on 11/02/2025.
//

import GoogleMapsUtils

extension GMSPath {
    var coords: [CLLocationCoordinate2D] {
        var coords: [CLLocationCoordinate2D] = []
        
        for i in 0..<count() {
            coords.append(coordinate(at: i))
        }
        
        return coords
    }
}
