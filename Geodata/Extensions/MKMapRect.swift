//
//  MKMapRect.swift
//  Cycle
//
//  Created by Jack Finnis on 17/02/2024.
//

import Foundation
import MapKit

extension MKMapRect {
    func padding(_ distance: Double = 10000) -> MKMapRect {
        insetBy(dx: -distance, dy: -distance)
    }
}

extension Array where Element: MKOverlay {
    var rect: MKMapRect {
        reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
    }
}

extension Array where Element: MKAnnotation {
    var rect: MKMapRect {
        let coords = map(\.coordinate)
        return MKPolyline(coords: coords).boundingMapRect
    }
}
