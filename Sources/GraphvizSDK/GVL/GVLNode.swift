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
    public private(set) var bezierPath: UIBezierPath = .init()
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
    
    public init(node: GVNode) {
         self.node = node
     }
    
    convenience init(parent: GVGraph, label: String) {
        let node = agnode(parent, cString(label), 1)
        self.init(node: node!)
        self.label = label
    }
    
    // MARK: - Layout Preparation
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
            bezierPath = UIBezierPath(cgPath: cgPath).rotate(degree: 180)
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
}

extension UIBezierPath {
    func rotate(degree: CGFloat) -> UIBezierPath {
        let bounds: CGRect = self.cgPath.boundingBox
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let radians = degree / 180.0 * .pi
        var transform: CGAffineTransform = .identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        self.apply(transform)
        return self
    }
}
