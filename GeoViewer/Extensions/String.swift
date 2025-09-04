//
//  String.swift
//  Geojson
//
//  Created by Jack Finnis on 07/02/2025.
//

import SwiftUI

extension String {
    var hexColor: UIColor? {
        UIColor(hex: self)
    }
    
    var removingStyleVariant: String {
        self.replacing("-normal", with: "")
            .replacing("-highlight", with: "")
    }
}
