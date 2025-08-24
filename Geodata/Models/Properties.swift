//
//  Properties.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import SwiftUI

struct Properties {
    let dict: [String : Any]
    
    var glyphText: String? {
        getStrings("symbol", "name").compactMap(Int.init).compactMap(String.init).first
    }
    var title: String? {
        getStrings("title", "name").first
    }
    var color: UIColor? {
        getStrings("color", "colour").first?.hexColor
    }
    
    func getTitle(key: String?) -> String? {
        key.map(getString) ?? title
    }
    func getString(_ key: String) -> String? {
        dict[key].map(String.init(describing:))
    }
    func getStrings(_ keys: String...) -> [String] {
        keys.compactMap(getString)
    }
    
    static var empty: Properties {
        .init(dict: [:])
    }
}
