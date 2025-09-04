//
//  Int.swift
//  Geojson
//
//  Created by Jack Finnis on 12/02/2025.
//

import Foundation

extension Int {
    func formatted(singular word: String) -> String {
        "\(self == 0 ? "No" : String(self)) \(word)\(self == 1 ? "" : "s")"
    }
}
