//
//  MapView.swift
//  Geojson
//
//  Created by Jack Finnis on 11/03/2024.
//

import SwiftUI
import MapKit

struct Map: UIViewRepresentable {
    @Binding var selectedAnnotation: Annotation?
    @Binding var zoomToAnnotation: Annotation?
    @Binding var refreshAnnotations: Bool
    let data: MapData
    let mapStandard: Bool
    let preview: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = context.coordinator.mapView
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = !preview
        mapView.isPitchEnabled = true
        mapView.selectableMapFeatures = .pointsOfInterest
        mapView.layoutMargins = preview ? .init(length: -25) : .init(top: 44 + 10 + 5, left: 5, bottom: 350, right: 5)
        mapView.showsUserTrackingButton = !preview
        mapView.pitchButtonVisibility = preview ? .hidden : .visible
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMarkerAnnotationView.id)
        mapView.register(AnnotationView.self, forAnnotationViewWithReuseIdentifier: AnnotationView.id)
        
        mapView.addAnnotations(data.points)
        mapView.addOverlays(data.multiPolylines, level: .aboveRoads)
        mapView.addOverlays(data.multiPolygons, level: .aboveRoads)
        mapView.setVisibleMapRect(data.rect, edgePadding: .init(length: preview ? 35 : 10), animated: false)
        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        mapView.addGestureRecognizer(tapRecognizer)
        let longPressRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.preferredConfiguration = mapStandard ? MKStandardMapConfiguration(elevationStyle: .realistic) : MKHybridMapConfiguration(elevationStyle: .realistic)
        
        if let selectedAnnotation {
            mapView.selectAnnotation(selectedAnnotation, animated: true)
        } else {
            mapView.selectedAnnotations.forEach { annotation in
                if let point = annotation as? Point {
                    mapView.deselectAnnotation(point, animated: true)
                }
            }
        }
        
        if !preview, refreshAnnotations {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                refreshAnnotations = false
            }
            mapView.removeAnnotations(data.polylines)
            mapView.removeAnnotations(data.polygons)
            mapView.removeAnnotations(data.points)
            if data.polylines.count < 1000 {
                mapView.addAnnotations(data.polylines)
            }
            if data.polygons.count < 1000 {
                mapView.addAnnotations(data.polygons)
            }
            mapView.addAnnotations(data.points)
        }
        
        if let annotation = zoomToAnnotation {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                zoomToAnnotation = nil
            }
            if let point = annotation as? Point {
                if !mapView.visibleMapRect.contains(MKMapPoint(point.coordinate)) {
                    mapView.setCenter(point.coordinate, animated: true)
                }
            } else if let overlay = annotation as? MKOverlay {
                if !mapView.visibleMapRect.contains(overlay.boundingMapRect) {
                    mapView.setVisibleMapRect(overlay.boundingMapRect, edgePadding: .init(length: 10), animated: true)
                }
            }
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: Map
        
        let mapView = MKMapView()
        
        init(_ parent: Map) {
            self.parent = parent
        }
        
        @available(iOS 18.0, *)
        func mapView(_ mapView: MKMapView, selectionAccessoryFor annotation: any MKAnnotation) -> MKSelectionAccessory? {
            .mapItemDetail(.openInMaps)
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
            if let annotation = annotation as? Annotation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parent.selectedAnnotation = annotation
                    self.parent.zoomToAnnotation = annotation
                }
            }
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: any MKOverlay) -> MKOverlayRenderer {
            let lineWidth = parent.preview ? 2.0 : 3.0
            if let multiPolyline = overlay as? MultiPolyline {
                let color = multiPolyline.color ?? defaultColor
                let renderer = MKMultiPolylineRenderer(multiPolyline: multiPolyline.mkMultiPolyline)
                renderer.lineWidth = lineWidth
                renderer.strokeColor = color
                return renderer
            } else if let multiPolygon = overlay as? MultiPolygon {
                let color = multiPolygon.color ?? defaultColor
                let renderer = MKMultiPolygonRenderer(multiPolygon: multiPolygon.mkMultiPolygon)
                renderer.lineWidth = lineWidth
                renderer.strokeColor = color
                renderer.fillColor = color.withAlphaComponent(0.2)
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
            if let annotation = annotation as? Annotation {
                if let point = annotation as? Point {
                    let marker = mapView.dequeueReusableAnnotationView(withIdentifier: MKMarkerAnnotationView.id, for: point) as? MKMarkerAnnotationView
                    marker?.titleVisibility = parent.preview ? .hidden : .adaptive
                    marker?.displayPriority = .required
                    marker?.glyphText = point.properties.glyphText
                    marker?.markerTintColor = point.color ?? UIColor(.orange)
                    return marker
                }
                return mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationView.id, for: annotation) as? AnnotationView
            }
            return nil
        }
        
        @objc
        func handleTap(_ tap: UITapGestureRecognizer) {
            let location = tap.location(in: mapView)
            let coord = mapView.convert(location, toCoordinateFrom: mapView)
            let overlay = parent.data.closestOverlay(to: coord)
            parent.selectedAnnotation = overlay
        }
        
        @objc
        func handleLongPress(_ press: UILongPressGestureRecognizer) {
            guard press.state == .began else { return }
            let location = press.location(in: mapView)
            let coord = mapView.convert(location, toCoordinateFrom: mapView)
            let mapItem = MKMapItem(placemark: .init(coordinate: coord))
            mapItem.name = "Dropped Pin"
            if #available(iOS 18, *), let annotation = MKMapItemAnnotation(mapItem: mapItem) {
                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: true)
                Haptics.tap()
            }
        }
    }
}
