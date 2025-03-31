//
//  File.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 25.03.2025.
//

#if SWIFT_PACKAGE
@preconcurrency import CGraphvizSDK
#endif
import UIKit
import CoreGraphics

public class GVLEdge {
    // MARK: - Properties
    private var _bounds: CGRect = .zero
    private var _frame: CGRect = .zero
    private var _bezierPath: UIBezierPath?
    private var _body: UIBezierPath?
    private var _head: UIBezierPath?
    private var _tail: UIBezierPath?
    
    // Graphviz pointers
    let edge: UnsafeMutablePointer<Agedge_t>
    private let parent: UnsafeMutablePointer<Agraph_t>
    
    // MARK: - Public Accessors
    public var frame: CGRect { _frame }
    public var bounds: CGRect { _bounds }
    public var path: UIBezierPath? { _bezierPath }
    public var body: UIBezierPath? { _body }
    public var headArrow: UIBezierPath? { _head }
    public var tailArrow: UIBezierPath? { _tail }
    
    // MARK: - Attribute Management
    public func setAttribute(_ value: String, forKey key: String) {
        agsafeset(edge, strdup(key), strdup(value), "")
    }
    
    public func getAttribute(forKey key: String) -> String {
        guard let cValue = agget(edge, strdup(key)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
    init(
        parent: UnsafeMutablePointer<Agraph_t>,
        edge: UnsafeMutablePointer<Agedge_t>
    ) {
        self.edge = edge
        self.parent = parent
    }
    
    convenience init(
        parent: UnsafeMutablePointer<Agraph_t>,
        from source: GVLNode,
        to target: GVLNode
    ) {
        self.init(parent: parent, edge: agedge(parent, source.node, target.node, nil, 1))
    }
    
    // MARK: - Layout Preparation
    public func prepare() {
        let splines = getED_spl(edge).pointee
        let graphHeight = GVLUtils.getHeight(for: parent)
        
        // Convert main spline
        let bodyPath = GVLUtils.toPath(splines: splines, height: graphHeight)
        _body = UIBezierPath(cgPath: bodyPath)
        _bezierPath = UIBezierPath(cgPath: bodyPath)
        
        // Create arrows
        _head = createArrow(from: splines, isHead: true, height: graphHeight)
        _tail = createArrow(from: splines, isTail: true, height: graphHeight)
        
        updateFrames()
        normalizePaths()
    }
    
    // MARK: - Private Methods
    private func updateFrames() {
        _frame = _body?.bounds ?? .zero
        
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
    
    private func createArrow(
        from splines: splines,
        isHead: Bool = false,
        isTail: Bool = false,
        height: CGFloat
    ) -> UIBezierPath? {
        let bezier = splines.list.pointee
        
        if isHead, bezier.eflag != 0 {
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
        
        if isTail, bezier.sflag != 0 {
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
        getED_spl(self).pointee
    }
}
