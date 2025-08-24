//
//  MRPolygon.swift
//  Geojson
//
//  Created by Jack Finnis on 10/03/2024.
//

import MapKit

extension MKPolygon {
    convenience init(exteriorCoords: [CLLocationCoordinate2D], interiorCoords: [[CLLocationCoordinate2D]]?) {
        self.init(
            coordinates: exteriorCoords,
            count: exteriorCoords.count,
            interiorPolygons: interiorCoords?.map { MKPolygon(coordinates: $0, count: $0.count) }
        )
    }
}
