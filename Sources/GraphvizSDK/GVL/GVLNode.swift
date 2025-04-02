//
//  File.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 25.03.2025.
//

import CGraphvizSDK
import UIKit
import CoreGraphics

public class GVLNode {
    // MARK: - Properties
    public private(set) var bezierPath: UIBezierPath?
    public private(set) var frame: CGRect = .zero
    public private(set) var bounds: CGRect = .zero
    public private(set) var origin: CGPoint = .zero
    
    public var label: String {
        get { getAttribute(forKey: .label) }
        set {
            setAttribute(newValue, forKey: .label)
        }
    }
    
    // Graphviz pointers
    public let node: GVNode
    private let parent: GVGraph
    
    // MARK: - Attribute Management
    public func setAttribute(_ value: String, forKey key: GVNodeParameters) {
        agsafeset(node, cString(key.rawValue), cString(value), "")
    }
    
    public func getAttribute(forKey key: GVNodeParameters) -> String {
        guard let cValue = agget(node, cString(key.rawValue)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
    public init(parent: GVGraph, node: GVNode) {
         self.parent = parent
         self.node = node
     }
    
    convenience init(parent: GVGraph, label: String) {
        var node = agnode(parent, cString(label), 0)
        if node == nil {
            node = agnode(parent, cString(label), 1)
        }
        self.init(parent: parent, node: node!)
        self.label = label
    }
    
    // MARK: - Layout Preparation
    @MainActor public func prepare() {
        let dpi = pointsPerInch
        
        // Get node dimensions
        let width = node.width
        let height = node.height
        
        // Get shape information
        guard let shape = nd_shape(node),
              let shapeName = shape.pointee.name,
              let shapeInfoPtr = nd_shape_info(node) else {
            return
        }
        
        // Convert to Swift types
        let type = String(cString: shapeName)
        let poly = shapeInfoPtr.assumingMemoryBound(to: polygon_t.self).pointee
        
        // Create path
        let cgPath = GVLUtils.toPath(
            type: NodeShapeType(rawValue: type) ?? .circle,
            poly: poly,
            width: width,
            height: height
        )
        bezierPath = UIBezierPath(cgPath: cgPath)
        
        
        // Calculate coordinates
        let graphHeight = GVLUtils.getHeight(for: parent)
        let coord = nd_coord(node)
        let point = GVLUtils.toPointF(coord, height: graphHeight)
        
        origin = GVLUtils.centerToOrigin(
            point,
            width: width,
            height: height
        )
        
        bounds = CGRect(x: 0, y: 0, width: width, height: height)
        frame = CGRect(x: origin.x, y: origin.y, width: width, height: height)
    }
}
