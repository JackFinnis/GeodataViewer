//
//  MapModel.swift
//  GeoStudio
//
//  Created by Jack Finnis on 06/10/2025.
//

import MapKit

@MainActor
@Observable
class MapModel: NSObject, Identifiable {
    let mapView = MKMapView()
    
    var mapStandard = true
    var selectedAnnotation: Annotation? { didSet {
        if let point = selectedAnnotation as? Point {
            if !mapView.visibleMapRect.contains(MKMapPoint(point.coordinate)) {
                mapView.setCenter(point.coordinate, animated: true)
            }
        } else if let overlay = selectedAnnotation as? MKOverlay {
            mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: .init(all: 10), animated: true)
        }
    }}
    
    func refreshAnnotation(_ annotation: Annotation) {
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
    }
}
