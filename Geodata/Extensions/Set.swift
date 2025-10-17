//
//  Set.swift
//  Visited
//
//  Created by Jack Finnis on 04/10/2024.
//

import Foundation

extension Set {
    mutating func toggle(_ element: Element) {
        if contains(element) {
            remove(element)
        } else {
            insert(element)
        }
    }
}
