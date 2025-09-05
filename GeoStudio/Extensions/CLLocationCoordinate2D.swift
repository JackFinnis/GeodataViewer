//
//  CLLocationCoordinate2D.swift
//  Visited
//
//  Created by Jack Finnis on 07/05/2023.
//

import MapKit

extension CLLocationCoordinate2D {
    var location: CLLocation {
        CLLocation(latitude: latitude, longitude: longitude)
    }
    
    var point: MKMapPoint {
        MKMapPoint(self)
    }
}
