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
        if let selectedAnnotation {
            zoomToAnnotation(selectedAnnotation)
        }
    }}
    
    func refreshAnnotation(_ annotation: Annotation) {
        mapView.removeAnnotation(annotation)
        mapView.addAnnotation(annotation)
    }
    
    func zoomToAnnotation(_ annotation: Annotation) {
        if let point = annotation as? Point {
            if !mapView.visibleMapRect.contains(MKMapPoint(point.coordinate)) {
                mapView.setCenter(point.coordinate, animated: true)
            }
        } else if let overlay = annotation as? MKOverlay {
            mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: .init(all: 20), animated: true)
        }
    }
}
