//
//  Node.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import UIKit
import CoreGraphics
import OSLog

public class Node: Equatable {
    // TODO: add image https://graphviz.org/docs/attrs/image/
    let node: GVNode
    
    public var label: String {
        get { getAttribute(forKey: .label) }
        set {
            setAttribute(newValue, forKey: .label)
        }
    }
    public private(set) var path: CGPath = .init(rect: .zero, transform: nil)
    public private(set) var frame: CGRect = .zero
    public private(set) var bounds: CGRect = .zero
    public private(set) var origin: CGPoint = .zero
    public var color: UIColor = UIColor.white
    public var highlihtedColor: UIColor = UIColor.lightGray
    public var borderColor: UIColor = UIColor.black // TODO: color https://graphviz.org/docs/attrs/color/
    public var borderWidth: Float = 1.0 // TODO: penwidth https://graphviz.org/docs/attrs/penwidth/
    public var textColor: UIColor = UIColor.black // TODO: fontcolor  https://graphviz.org/docs/attrs/fontcolor/
    public var fontSize: Int = 14 {
        didSet {
            setAttribute(fontSize.description, forKey: .fontsize)
        }
    }
    public var shape: GVNodeShape = .ellipse {
        didSet {
            setAttribute(shape.rawValue, forKey: .shape)
        }
    }
    public var width: Double = 1.0 {
        didSet {
            setAttribute(width.description, forKey: .width)
        }
    }
    public var height: Double = 1.0 {
        didSet {
            setAttribute(height.description, forKey: .height)
        }
    }
    
    public var style: GVNodeStyle {
        get { GVNodeStyle(rawValue: getAttribute(forKey: .style)) ?? .none }
        set {
            setAttribute(newValue.rawValue, forKey: .style)
        }
    }
    public func setAttribute(_ value: String, forKey key: GVNodeParameters) {
        agsafeset(node, cString(key.rawValue), cString(value), "")
    }
    
    public func getAttribute(forKey key: GVNodeParameters) -> String {
        guard let cValue = agget(node, cString(key.rawValue)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
    public init(node: GVNode) {
        self.node = node
    }
    
    convenience init(parent: GVGraph, label: String) {
        let node = agnode(parent, cString(label), 1)
        self.init(node: node!)
        self.label = label
    }
    
    public func setBaseParameters(params: [GVNodeParameters: String]) {
        params.forEach { setAttribute($0.value, forKey: $0.key) }
    }
    
    @MainActor public func prepare(graphHeight: CGFloat) {
        // Get node dimensions
        let width = node.width
        let height = node.height
        
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
        }
        
        
        // Calculate coordinates
        let coord = nd_coord(node)
        let point = coord.toCGPoint(graphHeight: graphHeight)
        
        origin = point.centerToOrigin(width: width, height: height)
        
        bounds = CGRect(x: 0, y: 0, width: width, height: height)
        frame = CGRect(x: origin.x, y: origin.y, width: width, height: height)
    }
    
    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
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
