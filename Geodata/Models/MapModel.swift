//
//  MapModel.swift
//  Geodata
//
//  Created by Jack Finnis on 06/10/2025.
//

import MapKit

@MainActor
@Observable
class MapModel: NSObject, Identifiable {
    let mapView = MKMapView()
    
    var mapStandard = true
    var visibleMapRect: MKMapRect?
    var selectedAnnotation: Annotation?
    
    func refreshAnnotations() {
        let annotations = mapView.annotations.filter { $0 is Annotation }
        mapView.removeAnnotations(annotations)
        mapView.addAnnotations(annotations)
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
