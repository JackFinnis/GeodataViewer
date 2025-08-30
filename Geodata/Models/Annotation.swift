//
//  Overlay.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    let file: File
    let coordinate: CLLocationCoordinate2D
    let properties: Properties
    let color: UIColor?
    
    var title: String? {
        properties.getTitle(key: file.titleKey)
    }
    
    init(file: File, coordinate: CLLocationCoordinate2D, properties: Properties, color: UIColor?) {
        self.file = file
        self.coordinate = coordinate
        self.properties = properties
        self.color = color
    }
}
