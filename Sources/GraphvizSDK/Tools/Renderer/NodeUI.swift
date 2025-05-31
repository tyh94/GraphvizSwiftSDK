//
//  NodeUI.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import SwiftUI
@preconcurrency import CGraphvizSDK
import OSLog

public struct NodeUI: Sendable, Identifiable {
    public let id: String
    public let label: String
    public let frame: CGRect
    public let bounds: CGRect
    public let origin: CGPoint
    public let path: Path
    public let borderWidth: CGFloat
    public let borderColor: Color
    public let textFont: Font
    public let textColor: Color
    public let imagePath: String?

    // Новый кэшированный UIImage (опционально)
    public var image: UIImage? = nil
}

extension Node {
    func create(graphHeight: CGFloat) -> NodeUI {
        // Get node dimensions
        let width = node.width
        let height = node.height
        let path: CGPath
        // Get shape information
        if let nodeType = node.nodeType,
           let poly = node.polygon {
            
            // Create path
            let cgPath = toPath(
                type: nodeType,
                poly: poly,
                width: width,
                height: height
            )
            path = cgPath.rotate(degree: 180)
        } else {
            path = CGPath(rect: .zero, transform: nil)
        }
        
        
        // Calculate coordinates
        let coord = nd_coord(node)
        let point = coord.toCGPoint(graphHeight: graphHeight)
        
        let origin = point.centerToOrigin(width: width, height: height)
        
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        let frame = CGRect(x: origin.x, y: origin.y, width: width, height: height)
        
        return NodeUI(
            id: name,
            label: label,
            frame: frame,
            bounds: bounds,
            origin: origin,
            path: Path(path),
            borderWidth: penwidth,
            borderColor: Color(borderColor),
            textFont: Font.custom(fontname, size: CGFloat(fontSize)),
            textColor: Color(textColor),
            imagePath: image.isEmpty ? nil : image
        )
    }
}

extension CGPath {
    fileprivate func rotate(degree: CGFloat) -> CGPath {
        let bounds: CGRect = self.boundingBox
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        
        let radians = degree / 180.0 * .pi
        var transform: CGAffineTransform = .identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        return self.copy(using: &transform)!
    }
}


private func toPolygon(_ poly: polygon_t, width: CGFloat, height: CGFloat) -> [CGPoint] {
    guard poly.peripheries == 1 else {
        Logger.graphviz.warning(message: "Unsupported number of peripheries \(poly.peripheries)")
        return []
    }
    
    return (0..<poly.sides).map { side in
        let vertex = poly.vertices[side]
        return CGPoint(
            x: CGFloat(vertex.x) + width/2,
            y: CGFloat(vertex.y) + height/2
        )
    }
}

// MARK: - Path Conversion

private func toPath(type: GVNodeShape, poly: polygon_t, width: CGFloat, height: CGFloat) -> CGPath {
    var points = toPolygon(poly, width: width, height: height)
    if points.count == 2 {
        let points = toPolygon(poly, width: width, height: height)
        
        let p1 = points[0]
        let p2 = points[1]
        let rect = CGRect(origin: p1, size: CGSize(width: p2.x, height: p2.y))
        return CGPath(ellipseIn: rect, transform: nil)
    }
    
    if let first = points.first {
        points.append(first)
    }
    return toPath(points: points)
}

// TODO: corners https://github.com/DuncanMC/RoundedCornerPolygon
private func toPath(points: [CGPoint]) -> CGPath {
    let path = CGMutablePath()
    guard let first = points.first else { return path }
    
    path.move(to: first)
    for point in points.dropFirst() {
        path.addLine(to: point)
    }
    return path
}
