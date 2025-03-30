//
//  Edge.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//


import UIKit

public class Edge: Equatable {
    fileprivate let gvlEdge: GVLEdge

    public let from: Node
    public let to: Node
    public var color: UIColor = UIColor.black
    public var width: Float = 1.0
    public var weight: Float = 1 {
        didSet {
            setAttribute(name: "weight", value: weight.description)
        }
    }

    public init(gvlEdge: GVLEdge, from: Node, to: Node) {
        self.gvlEdge = gvlEdge
        self.from = from
        self.to = to
    }

    public func getAttribute(name: String) -> String? {
        gvlEdge.getAttribute(forKey: name)
    }

    func setAttribute(name: String, value: String) {
        gvlEdge.setAttribute(value, forKey: name)
    }
    
    public func setNoDirection() {
        gvlEdge.setAttribute("dir", forKey: "none")
    }

    public func frame() -> CGRect? {
        gvlEdge.frame
    }

    public func bounds() -> CGRect? {
        gvlEdge.bounds
    }

    public func body() -> UIBezierPath? {
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
