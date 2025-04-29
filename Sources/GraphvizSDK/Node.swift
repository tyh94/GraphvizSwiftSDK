//
//  Node.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import UIKit
import CoreGraphics

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
            let cgPath = GVLUtils.toPath(
                type: nodeType,
                poly: poly,
                width: width,
                height: height
            )
            path = cgPath.rotate(degree: 180)
        }
        
        
        // Calculate coordinates
        let coord = nd_coord(node)
        let point = coord.toCGPoint(height: graphHeight)
        
        origin = GVLUtils.centerToOrigin(
            point,
            width: width,
            height: height
        )
        
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
