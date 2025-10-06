//
//  MapView.swift
//  Geojson
//
//  Created by Jack Finnis on 11/03/2024.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    let mapModel: MapModel
    let recordModel: RecordModel?
    let data: MapData
    let preview: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = mapModel.mapView
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = !preview
        mapView.isPitchEnabled = true
        mapView.selectableMapFeatures = .pointsOfInterest
        mapView.layoutMargins = preview ? .init(all: -25) : .init(top: 0, left: 0, bottom: horizontalSizeClass == .compact ? 350 : 0, right: 0)
        mapView.showsUserTrackingButton = !preview
        mapView.pitchButtonVisibility = preview ? .hidden : .visible
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMarkerAnnotationView.id)
        mapView.register(AnnotationLabel.self, forAnnotationViewWithReuseIdentifier: AnnotationLabel.id)
        
        let tapRecognizer = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        mapView.addGestureRecognizer(tapRecognizer)
        let longPressRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress))
        mapView.addGestureRecognizer(longPressRecognizer)
        
        mapView.addAnnotations(data.points)
        mapView.addOverlays(data.multiPolylines, level: .aboveRoads)
        mapView.addOverlays(data.multiPolygons, level: .aboveRoads)
        if !preview {
            if data.polylines.count < 1000 {
                mapView.addAnnotations(data.polylines)
            }
            if data.polygons.count < 1000 {
                mapView.addAnnotations(data.polygons)
            }
            mapView.addAnnotations(data.points)
        }
        
        DispatchQueue.main.async {
            if data == .empty {
                mapView.userTrackingMode = .follow
            } else {
                mapView.setVisibleMapRect(data.rect, edgePadding: .init(all: preview ? 35 : 10), animated: false)
            }
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if mapModel.mapStandard {
            let config = MKStandardMapConfiguration(elevationStyle: .realistic)
            config.pointOfInterestFilter = preview ? .excludingAll : .includingAll
            mapView.preferredConfiguration = config
        } else {
            let config = MKHybridMapConfiguration(elevationStyle: .realistic)
            config.pointOfInterestFilter = preview ? .excludingAll : .includingAll
            mapView.preferredConfiguration = config
        }
        
        mapView.removeOverlays(mapView.overlays(in: .aboveLabels))
        if let recordModel {
            mapView.addOverlays(recordModel.polylines, level: .aboveLabels)
        }
        if let polyline = mapModel.selectedAnnotation as? Polyline {
            mapView.addOverlay(polyline.mkPolyline, level: .aboveLabels)
        } else if let polygon = mapModel.selectedAnnotation as? Polygon {
            mapView.addOverlay(polygon.mkPolygon, level: .aboveLabels)
        }
        
        if let selectedAnnotation = mapModel.selectedAnnotation {
            mapView.selectAnnotation(selectedAnnotation, animated: true)
        } else {
            mapView.selectedAnnotations.forEach { annotation in
                if let point = annotation as? Point {
                    mapView.deselectAnnotation(point, animated: true)
                }
            }
        }
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        let parent: MapViewRepresentable
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, selectionAccessoryFor annotation: any MKAnnotation) -> MKSelectionAccessory? {
            .mapItemDetail(.openInMaps)
        }
        
        func mapView(_ mapView: MKMapView, didSelect annotation: any MKAnnotation) {
            if let annotation = annotation as? Annotation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.parent.mapModel.selectedAnnotation = annotation
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
            } else if let polyline = overlay as? MKPolyline {
                let color = UIColor(.blue)
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.lineWidth = lineWidth
                renderer.strokeColor = color
                return renderer
            } else if let polygon = overlay as? MKPolygon {
                let color = UIColor(.blue)
                let renderer = MKPolygonRenderer(polygon: polygon)
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
                return mapView.dequeueReusableAnnotationView(withIdentifier: AnnotationLabel.id, for: annotation)
            }
            return nil
        }
        
        @objc
        func handleTap(_ tap: UITapGestureRecognizer) {
            let mapView = parent.mapModel.mapView
            let location = tap.location(in: mapView)
            let coord = mapView.convert(location, toCoordinateFrom: mapView)
            let overlay = parent.data.closestOverlay(to: coord)
            parent.mapModel.selectedAnnotation = overlay
        }
        
        @objc
        func handleLongPress(_ press: UILongPressGestureRecognizer) {
            guard press.state == .began else { return }
            let mapView = parent.mapModel.mapView
            let location = press.location(in: mapView)
            let coord = mapView.convert(location, toCoordinateFrom: mapView)
            let mapItem = MKMapItem(location: coord.location, address: nil)
            mapItem.name = "Dropped Pin"
            if let annotation = MKMapItemAnnotation(mapItem: mapItem) {
                mapView.addAnnotation(annotation)
                mapView.selectAnnotation(annotation, animated: true)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapView(title: .constant("Example"), data: .example)
    }
    .environment(Model())
}
