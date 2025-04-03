//
//  File.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 25.03.2025.
//

@preconcurrency import CGraphvizSDK
import UIKit
import CoreGraphics

public class GVLEdge {
    // MARK: - Properties
    private var _bounds: CGRect = .zero
    private var _frame: CGRect = .zero
    private var _bezierPath: UIBezierPath = .init()
    private var _body: UIBezierPath = .init()
    private var _head: UIBezierPath?
    private var _tail: UIBezierPath?
    
    // Graphviz pointers
    let edge: GVEdge
    private let parent: GVGraph
    
    // MARK: - Public Accessors
    public var frame: CGRect { _frame }
    public var bounds: CGRect { _bounds }
    public var path: UIBezierPath { _bezierPath }
    public var body: UIBezierPath { _body }
    public var headArrow: UIBezierPath? { _head }
    public var tailArrow: UIBezierPath? { _tail }
    
    // MARK: - Attribute Management
    public func setAttribute(_ value: String, forKey key: GVEdgeParameters) {
        agsafeset(edge, cString(key.rawValue), cString(value), "")
    }
    
    public func getAttribute(forKey key: GVEdgeParameters) -> String {
        guard let cValue = agget(edge, cString(key.rawValue)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
    init(
        parent: GVGraph,
        edge: GVEdge
    ) {
        self.edge = edge
        self.parent = parent
    }
    
    convenience init(
        parent: GVGraph,
        from source: GVLNode,
        to target: GVLNode
    ) {
        var edge = agedge(parent, source.node, target.node, nil, 0)
        if edge == nil {
            edge = agedge(parent, source.node, target.node, nil, 1)
        }
        self.init(parent: parent, edge: edge!)
    }
    
    // MARK: - Layout Preparation
    public func prepare() {
        let splines = ed_spl(edge).pointee
        let graphHeight = GVLUtils.getHeight(for: parent)
        
        // Convert main spline
        let bodyPath = GVLUtils.toPath(splines: splines, height: graphHeight)
        _body = UIBezierPath(cgPath: bodyPath)
        _bezierPath = UIBezierPath(cgPath: bodyPath)
        
        // Create arrows
        _head = createHeadArrow(from: splines, height: graphHeight)
        _tail = createTailArrow(from: splines, height: graphHeight)
        
        updateFrames()
        normalizePaths()
    }
    
    // MARK: - Private Methods
    private func updateFrames() {
        _frame = _body.bounds
        
        if let headBounds = _head?.bounds {
            _frame = _frame.union(headBounds)
        }
        
        if let tailBounds = _tail?.bounds {
            _frame = _frame.union(tailBounds)
        }
        
        _bounds = CGRect(
            origin: .zero,
            size: CGSize(
                width: _frame.width,
                height: _frame.height
            )
        )
    }
    
    private func normalizePaths() {
        let translation = CGAffineTransform(
            translationX: -_frame.origin.x,
            y: -_frame.origin.y
        )
        
        [_body, _head, _tail].forEach {
            $0?.apply(translation)
        }
    }
    
    private func createHeadArrow(
        from splines: splines,
        height: CGFloat
    ) -> UIBezierPath? {
        let bezier = splines.list.pointee
        
        if bezier.eflag != 0 {
            let lastIndex = Int(bezier.size) - 1
            let p1 = GVLUtils.toPointF(bezier.list[lastIndex], height: height)
            let p2 = GVLUtils.toPointF(bezier.ep, height: height)
            return GVLUtils.arrow(
                from: p1,
                to: p2,
                tailWidth: 0.5,
                headWidth: 8,
                headLength: 12
            )
        }
        
        return nil
    }
    
    private func createTailArrow(
        from splines: splines,
        height: CGFloat
    ) -> UIBezierPath? {
        let bezier = splines.list.pointee
        
        if bezier.sflag != 0 {
            let p1 = GVLUtils.toPointF(bezier.sp, height: height)
            let p2 = GVLUtils.toPointF(bezier.list[0], height: height)
            return GVLUtils.arrow(
                from: p1,
                to: p2,
                tailWidth: 0.5,
                headWidth: 8,
                headLength: 12
            )
        }
        
        return nil
    }
}

// MARK: - Graphviz C API Extensions
extension UnsafeMutablePointer<Agedge_s> {
    var splines: splines? {
        ed_spl(self).pointee
    }
}
