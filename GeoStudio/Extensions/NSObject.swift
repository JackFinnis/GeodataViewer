//
//  NSObject.swift
//  Geojson
//
//  Created by Jack Finnis on 13/02/2025.
//

import Foundation

extension NSObject {
    static var id: String {
        String(describing: self)
    }
}
