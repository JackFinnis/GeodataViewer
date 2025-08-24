//
//  FileView.swift
//  Geojson
//
//  Created by Jack Finnis on 11/03/2024.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @Binding var selectedAnnotation: Annotation?

    let file: File
    let data: GeoData
    let mapStandard: Bool
    let preview: Bool
    
    let mapView = MKMapView()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = !preview
        mapView.isPitchEnabled = true
        mapView.selectableMapFeatures = .pointsOfInterest
        mapView.layoutMargins = .init(length: preview ? -25 : 5)
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
        
        if selectedAnnotation == nil {
            mapView.selectedAnnotations.forEach { annotation in
                if let point = annotation as? Point {
                    mapView.deselectAnnotation(point, animated: true)
                }
            }
        }
        
        if !preview, file.titleKey != context.coordinator.titleKey {
            context.coordinator.titleKey = file.titleKey
            mapView.removeAnnotations(data.polylines)
            mapView.removeAnnotations(data.polygons)
            mapView.removeAnnotations(data.points)
            mapView.addAnnotations(data.polylines)
            mapView.addAnnotations(data.polygons)
            mapView.addAnnotations(data.points)
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapView
        var titleKey: String? = ""
        
        init(_ parent: MapView) {
            self.parent = parent
        }
        
        @available(iOS 18.0, *)
        func mapView(_ mapView: MKMapView, selectionAccessoryFor annotation: any MKAnnotation) -> MKSelectionAccessory? {
            .mapItemDetail(.openInMaps)
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
            if let annotation = annotation as? Annotation {
                parent.selectedAnnotation = annotation
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
                annotation.updateTitle(key: titleKey)
                
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
            let mapView = parent.mapView
            let location = tap.location(in: mapView)
            let coord = mapView.convert(location, toCoordinateFrom: mapView)
            let overlay = parent.data.closestOverlay(to: coord)
            parent.selectedAnnotation = overlay
        }
        
        @objc
        func handleLongPress(_ press: UILongPressGestureRecognizer) {
            let mapView = parent.mapView
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
