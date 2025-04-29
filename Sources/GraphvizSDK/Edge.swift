//
//  Edge.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import UIKit
import CoreGraphics

public class Edge: Equatable {
    let edge: GVEdge
    public var color: UIColor = UIColor.black
    public var width: Float = 1.0
    
    // MARK: - Public Accessors
    public var frame: CGRect = .zero
    public var bounds: CGRect = .zero
    public var body: CGPath = .init(rect: .zero, transform: nil)
    public var headArrow: CGPath?
    public var tailArrow: CGPath?
    public var weight: Float {
        get { Float(getAttribute(forKey: .weight)) ?? 1 }
        set {
            setAttribute(newValue.description, forKey: .weight)
        }
    }
    public var arrowheadType: GVEdgeEnding {
        get { GVEdgeEnding(rawValue: getAttribute(forKey: .arrowhead)) ?? .normal }
        set { setAttribute(newValue.rawValue, forKey: .arrowhead) }
    }
    
    public var arrowtailType: GVEdgeEnding {
        get { GVEdgeEnding(rawValue: getAttribute(forKey: .arrowtail)) ?? .normal }
        set { setAttribute(newValue.rawValue, forKey: .arrowtail) }
    }
    
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
        edge: GVEdge
    ) {
        self.edge = edge
    }
    
    convenience init(
        parent: GVGraph,
        from source: Node,
        to target: Node
    ) {
        let edge = agedge(parent, source.node, target.node, nil, 1)
        self.init(edge: edge!)
    }
    
    public func setNoDirection() {
        setAttribute(GVEdgeParamDir.none.rawValue, forKey: .dir)
    }
    
    // MARK: - Layout Preparation
    public func prepare(graphHeight: CGFloat) {
        guard let pathPoints = edge.getPath(),
                  !pathPoints.isEmpty else {
                return
            }
        
        let cgPath = pathPoints.map { $0.convertFromGraphviz(graphHeight: graphHeight) }
        let buildPath = CGMutablePath()
        buildPath.move(to: cgPath[0])
        
        for i in stride(from: 1, to: cgPath.count, by: 3) {
            guard i+2 < cgPath.count else { break }
            buildPath.addCurve(to: cgPath[i + 2], control1: cgPath[i], control2: cgPath[i + 1])
        }
        
        body = buildPath
        
        // Create arrows
        if let arrowHead = edge.arrowHead?.convertFromGraphviz(graphHeight: graphHeight) {
            let arrowHead2 = cgPath[cgPath.count - 1]
            let headPath = definePath(pos: arrowHead, type: arrowheadType, otherPoint: arrowHead2)
            headArrow = headPath
        }
        
        if let arrowTail = edge.arrowTail?.convertFromGraphviz(graphHeight: graphHeight) {
            let arrowTail2 = cgPath[0]
            let tailPath = definePath(pos: arrowTail, type: arrowtailType, otherPoint: arrowTail2)
            tailArrow = tailPath
        }
    }
    
    private func definePath(pos: CGPoint, type: GVEdgeEnding, otherPoint: CGPoint) -> CGPath {
        switch type {
        case .normal :
            return CGPath.arrow(startPoint: otherPoint, endPoint: pos, tailWidth: 2, headWidth: 8, headLength: otherPoint.distance(to: pos))
        case .dot:
            return UIBezierPath(circleBetween: pos, and: otherPoint).cgPath
        case .none:
            let path = CGMutablePath()
            path.move(to: pos)
            path.addLine(to: otherPoint)
            return path
        case  .diamond:
            return UIBezierPath(diamondBetween: pos, and: otherPoint).cgPath
        }
    }

    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs === rhs
    }
}
