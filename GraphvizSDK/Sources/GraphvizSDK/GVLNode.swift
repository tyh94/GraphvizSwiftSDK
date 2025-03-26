//
//  File.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 25.03.2025.
//

//#if SWIFT_PACKAGE
import CGraphvizSDK
//#endif
import UIKit
import CoreGraphics

public class GVLNode {
    // MARK: - Properties
    public private(set) var bezierPath: UIBezierPath?
    public private(set) var frame: CGRect = .zero
    public private(set) var bounds: CGRect = .zero
    public private(set) var origin: CGPoint = .zero
    
    private var _label: String = ""
    public var label: String {
        get { _label }
        set {
            _label = newValue
            setAttribute(newValue, forKey: "label")
        }
    }
    
    // Graphviz pointers
    var node: UnsafeMutablePointer<Agnode_t>!
    var parent: UnsafeMutablePointer<Agraph_t>!
    
    // MARK: - Attribute Management
    public func setAttribute(_ value: String, forKey key: String) {
        key.withCString { cKey in
            value.withCString { cValue in
                agsafeset(node, UnsafeMutablePointer(mutating: cKey), UnsafeMutablePointer(mutating: cValue), "")
            }
        }
    }
    
    public func getAttribute(forKey key: String) -> String {
        guard let cValue = key.withCString({ agget(node, UnsafeMutablePointer(mutating: $0)) }) else {
            return ""
        }
        return String(cString: cValue)
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

// MARK: - Graphviz C API Extensions
//extension Agnode_s {
//    var shape: shape_desc? {
//        get { getND_shape(self).pointee }
//        set { getND_shape(self) = newValue }
//    }
//    
//    var shapeInfo: UnsafeMutableRawPointer? {
//        get { getND_shape_info(self) }
//        set { getND_shape_info(self) = newValue }
//    }
//    
//    var width: Double {
//        get { getND_width(self) }
//        set { getND_width(self) = newValue }
//    }
//    
//    var height: Double {
//        get { getND_height(self) }
//        set { getND_height(self) = newValue }
//    }
//    
//    var coord: pointf {
//        get { getND_coord(self) }
//        set { getND_coord(self) = newValue }
//    }
//}
