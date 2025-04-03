//
//  Edge.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//


import UIKit

public class Edge: Equatable {
    fileprivate let gvlEdge: GVLEdge

    public var color: UIColor = UIColor.black
    public var width: Float = 1.0
    public var weight: Float {
        get { Float(getAttribute(name: .weight)) ?? 1 }
        set {
            setAttribute(name: .weight, value: weight.description)
        }
    }
    
    public var style: GVEdgeStyle {
        get { GVEdgeStyle(rawValue: getAttribute(name: .style)) ?? .none }
        set {
            setAttribute(name: .style, value: newValue.rawValue)
        }
    }

    public init(gvlEdge: GVLEdge) {
        self.gvlEdge = gvlEdge
    }

    public func getAttribute(name: GVEdgeParameters) -> String {
        gvlEdge.getAttribute(forKey: name)
    }

    func setAttribute(name: GVEdgeParameters, value: String) {
        gvlEdge.setAttribute(value, forKey: name)
    }
    
    public func setNoDirection() {
        gvlEdge.setAttribute(GVEdgeParamDir.none.rawValue, forKey: .dir)
    }

    public func frame() -> CGRect {
        gvlEdge.frame
    }

    public func bounds() -> CGRect {
        gvlEdge.bounds
    }

    public func body() -> UIBezierPath {
        gvlEdge.body
    }

    public func headArrow() -> UIBezierPath? {
        gvlEdge.headArrow
    }

    public func tailArrow() -> UIBezierPath? {
        gvlEdge.tailArrow
    }

    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs === rhs
    }
}
