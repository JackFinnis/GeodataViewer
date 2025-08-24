//
//  AnnotationView.swift
//  Geojson
//
//  Created by Jack Finnis on 13/02/2025.
//

import MapKit
import UIKit

class AnnotationView: MKAnnotationView {
    let label = MapLabel()
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    func setup() {
        frame = CGRect(x: 0, y: 0, width: 150, height: 50)
        
        label.frame = frame
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        addSubview(label)
        
        displayPriority = .defaultHigh
        collisionMode = .rectangle
    }
    
    override var annotation: MKAnnotation? {
        didSet {
            label.text = annotation?.title ?? nil
        }
    }
    
    override func prepareForReuse() {
        label.text = nil
    }
}

class MapLabel: UILabel {
    override func drawText(in rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        context?.setLineJoin(CGLineJoin.round)
        context?.setTextDrawingMode(CGTextDrawingMode.stroke)
        textColor = .systemBackground
        super.drawText(in: rect)
        
        context?.setTextDrawingMode(.fill)
        textColor = .label
        super.drawText(in: rect)
    }
}
