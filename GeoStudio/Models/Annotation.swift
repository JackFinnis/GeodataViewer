//
//  Overlay.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import MapKit

class Annotation: NSObject, MKAnnotation, Identifiable {
    let id = UUID()
    let file: File
    let coordinate: CLLocationCoordinate2D
    let properties: Properties
    let color: UIColor?
    
    var title: String? {
        properties.getTitle(key: file.titleKey)
    }
    var type: AnnotationType {
        switch self {
        case is Point:
            return .point
        case is Polyline:
            return .polyline
        case is Polygon:
            return .polygon
        default: fatalError()
        }
    }
    
    init(file: File, coordinate: CLLocationCoordinate2D, properties: Properties, color: UIColor?) {
        self.file = file
        self.coordinate = coordinate
        self.properties = properties
        self.color = color
    }
}

enum AnnotationType: String {
    case point, polyline, polygon
    
    var name: String {
        rawValue.capitalized
    }
    
    var systemImage: String {
        switch self {
        case .point:
            return "mappin"
        case .polyline:
            return "point.topleft.down.to.point.bottomright.curvepath.fill"
        case .polygon:
            return "pentagon"
        }
    }
}
