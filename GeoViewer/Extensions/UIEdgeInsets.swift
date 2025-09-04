//
//  UIEdgePadding.swift
//  Geojson
//
//  Created by Jack Finnis on 24/05/2024.
//

import UIKit

extension UIEdgeInsets {
    init(length: CGFloat) {
        self.init(top: length, left: length, bottom: length, right: length)
    }
}
