//
//  Overlay.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import MapKit

class Annotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let properties: Properties
    let color: UIColor?
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, properties: Properties, color: UIColor?) {
        self.coordinate = coordinate
        self.properties = properties
        self.color = color
        self.title = properties.title
    }
    
    func updateTitle(key: String?) {
        title = properties.getTitle(key: key)
    }
}
