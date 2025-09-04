//
//  MKPolyline.swift
//  Geojson
//
//  Created by Jack Finnis on 10/03/2024.
//

import MapKit

extension MKPolyline {
    convenience init(coords: [CLLocationCoordinate2D]) {
        self.init(coordinates: coords, count: coords.count)
    }
}
