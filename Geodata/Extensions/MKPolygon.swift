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
    
    var squareMeters: Double {
        guard pointCount > 2 else { return 0 }
        
        let points = points()
        var sum = 0.0
        
        for i in 0..<pointCount {
            let p1 = points[i]
            let p2 = points[(i + 1) % pointCount]
            sum += (p1.x * p2.y) - (p2.x * p1.y)
        }
        
        let mppm = MKMetersPerMapPointAtLatitude(coordinate.latitude)
        var area = abs(0.5 * sum) * mppm * mppm
        
        if let holes = interiorPolygons {
            for hole in holes { area -= hole.squareMeters }
        }
        
        return area
    }
}
