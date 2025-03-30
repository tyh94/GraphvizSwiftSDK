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
        get { getAttribute(forKey: "label") }
        set {
            setAttribute(newValue, forKey: "label")
        }
    }
    
    // Graphviz pointers
    let node: UnsafeMutablePointer<Agnode_t>
    private let parent: UnsafeMutablePointer<Agraph_t>
    
    // MARK: - Attribute Management
    public func setAttribute(_ value: String, forKey key: String) {
        agsafeset(node, strdup(key), strdup(value), "")
    }
    
    public func getAttribute(forKey key: String) -> String {
        guard let cValue = agget(node, strdup(key)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
     init(parent: UnsafeMutablePointer<Agraph_t>, node: UnsafeMutablePointer<Agnode_t>) {
         self.parent = parent
         self.node = node
     }
    
    convenience init(parent: UnsafeMutablePointer<Agraph_t>, label: String) {
        self.init(parent: parent, node: agnode(parent, nil, 1))
        self.label = label
    }
    
    // MARK: - Layout Preparation
    @MainActor public func prepare() {
        let dpi = GVLConfig.dpi
        
        // Get node dimensions
        let width = CGFloat(getND_width(node)) * dpi
        let height = CGFloat(getND_height(node)) * dpi
        
        // Get shape information
        guard let shape = getND_shape(node),
              let shapeName = shape.pointee.name,
              let shapeInfoPtr = get_shape_info(node) else {
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
        let coord = getND_coord(node)
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
