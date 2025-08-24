//
//  View.swift
//  Geojson
//
//  Created by Jack Finnis on 07/07/2024.
//

import SwiftUI

extension View {
    func mapBox() -> some View {
        frame(width: 44, height: 44)
    }
    
    func mapButton() -> some View {
        self
            .foregroundStyle(Color.accentColor)
            .buttonStyle(.plain)
            .font(.system(size: 20))
            .background(.ultraThickMaterial)
            .clipShape(.rect(cornerRadius: 8))
    }
    
    @ViewBuilder
    func zoomParent(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
    
    @ViewBuilder
    func zoomChild(id: some Hashable, in namespace: Namespace.ID) -> some View {
        if #available(iOS 18, *) {
            navigationTransition(.zoom(sourceID: id, in: namespace))
        } else {
            self
        }
    }
}
