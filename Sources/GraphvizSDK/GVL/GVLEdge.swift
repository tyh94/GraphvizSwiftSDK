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
    // Graphviz pointers
    let edge: GVEdge
    private let parent: GVGraph
    
    // MARK: - Public Accessors
    public var frame: CGRect = .zero
    public var bounds: CGRect = .zero
    public var body: UIBezierPath = .init()
    public var headArrow: UIBezierPath?
    public var tailArrow: UIBezierPath?
    
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
        let graphHeight = parent.height
        
        
        let cgPath = try! edge.getPath().map { $0.revertY(height: graphHeight) }
        let buildPath = CGMutablePath()
        buildPath.move(to: cgPath[0])
        
        for i in stride(from: 1, to: cgPath.count, by: 3) {
            buildPath.addCurve(to: cgPath[i + 2], control1: cgPath[i], control2: cgPath[i + 1])
        }
        
        body = UIBezierPath(cgPath: buildPath)
        
        // Create arrows
        if let arrowHead = edge.arrowHead?.revertY(height: graphHeight) {
            let arrowHead2 = cgPath[cgPath.count - 1]
            let headPath = definePath(pos: arrowHead, type: .normal, otherPoint: arrowHead2)
            headArrow = headPath
        }
        
        if let arrowTail = edge.arrowTail?.revertY(height: graphHeight) {
            let arrowTail2 = cgPath[0]
            let tailPath = definePath(pos: arrowTail, type: .normal, otherPoint: arrowTail2)
            tailArrow = tailPath
        }
        updateFrames()
        normalizePaths()
    }
    
    // MARK: - Private Methods
    private func updateFrames() {
        frame = body.bounds
        
        if let headBounds = headArrow?.bounds {
            frame = frame.union(headBounds)
        }
        
        if let tailBounds = tailArrow?.bounds {
            frame = frame.union(tailBounds)
        }
        
        bounds = CGRect(
            origin: .zero,
            size: CGSize(
                width: frame.width,
                height: frame.height
            )
        )
    }
    
    private func normalizePaths() {
        let translation = CGAffineTransform(
            translationX: -frame.origin.x,
            y: -frame.origin.y
        )
        
        [body, headArrow, tailArrow].forEach {
            $0?.apply(translation)
        }
    }
    
    private func definePath (pos: CGPoint, type: GVEdgeEnding, otherPoint: CGPoint) -> UIBezierPath {
        switch type {
        case .normal :
            return UIBezierPath.arrow(startPoint: otherPoint, endPoint: pos, tailWidth: 2, headWidth: 8, headLength: otherPoint.distance(to: pos))
        case .dot:
            return UIBezierPath(circleBetween: pos, and: otherPoint)
        case .none:
            let path = UIBezierPath()
            path.move(to: pos)
            path.addLine(to: otherPoint)
            return path
        case  .diamond:
            return UIBezierPath(diamondBetween: pos, and: otherPoint)
        }
    }
}
