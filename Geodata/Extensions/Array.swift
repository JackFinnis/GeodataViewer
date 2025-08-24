//
//  Array.swift
//  Geojson
//
//  Created by Jack Finnis on 11/05/2023.
//

import Foundation
import MapKit

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
    
    var second: Element? {
        self[safe: 1]
    }
    
    var middle: Element? {
        self[safe: count/2]
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
