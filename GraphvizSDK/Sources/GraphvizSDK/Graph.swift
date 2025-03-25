//
//  Graph.swift
//  GraphLayout
//
//  Copyright © 2018 bakhtiyor.com.
//  MIT License
//

import UIKit

public enum Shape: String {
    case rectangle, box, hexagon, polygon, diamond, star, ellipse, circle
}

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
        gvlEdge.getAttributeForKey(name)
    }

    func setAttribute(name: String, value: String) {
        gvlEdge.setAttribute(value, forKey: name)
    }

    public func frame() -> CGRect? {
        gvlEdge.frame()
    }

    public func bounds() -> CGRect? {
        gvlEdge.bounds()
    }

    public func body() -> UIBezierPath? {
        gvlEdge.body()
    }

    public func headArrow() -> UIBezierPath? {
        gvlEdge.headArrow()
    }

    public func tailArrow() -> UIBezierPath? {
        gvlEdge.tailArrow()
    }

    public static func == (lhs: Edge, rhs: Edge) -> Bool {
        return lhs === rhs
    }
}

public class Node: Equatable {
    fileprivate var gvlNode: GVLNode

    public var label: String {
        gvlNode.label ?? ""
    }
    public var color: UIColor = UIColor.white
    public var highlihtedColor: UIColor = UIColor.lightGray
    public var borderColor: UIColor = UIColor.black
    public var borderWidth: Float = 1.0
    public var textColor: UIColor = UIColor.black
    public var fontSize: Int = 14 {
        didSet {
            setAttribute(name: "fontsize", value: fontSize.description)
        }
    }
    public var shape: Shape = .ellipse {
        didSet {
            setAttribute(name: "shape", value: shape.rawValue)
        }
    }

    public init(gvlNode: GVLNode) {
        self.gvlNode = gvlNode
    }

    public func getAttribute(name: String) -> String? {
        gvlNode.getAttributeForKey(name)
    }

    func setAttribute(name: String, value: String) {
        gvlNode.setAttribute(value, forKey: name)
    }

    public func frame() -> CGRect? {
        gvlNode.frame()
    }

    public func bounds() -> CGRect? {
        gvlNode.bounds()
    }

    public func path() -> UIBezierPath? {
        gvlNode.path()
    }

    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
    }
}

public class SubGraph {
}

public enum Splines: String {
    case spline
    case polyline
    case ortho
    case curved
}

public class Graph {
    fileprivate var gvlGraph: GVLGraph

    public private(set) var nodes = [Node]()
    public private(set) var edges = [Edge]()
    public var size: CGSize {
        gvlGraph.size()
    }
    public var splines: Splines = .spline {
        didSet {
            gvlGraph.setAttribute(splines.rawValue, forKey: "splines")
        }
    }

    public init() {
        gvlGraph = GVLGraph()
    }

    public func addNode(_ label: String) -> Node {
        let gvlNode = gvlGraph.addNode(label)!
        let node = Node(gvlNode: gvlNode)
        nodes.append(node)
        return node
    }

    public func removeNode(node: Node) {
        guard nodes.count > 1 else { return }
        if let index = nodes.index(of: node) {
            for edge in edges {
                if edge.from == node || edge.to == node {
                    removeEdge(edge: edge)
                }
            }
            nodes.remove(at: index)
        }
    }

    public func addEdge(from: Node, to: Node) -> Edge {
        let gvlEdge = gvlGraph.addEdge(withSource: from.gvlNode, andTarget: to.gvlNode)
        let edge = Edge(gvlEdge: gvlEdge!, from: from, to: to)
        edges.append(edge)
        return edge
    }

    public func removeEdge(edge: Edge) {
        if let index = edges.index(of: edge) {
            edges.remove(at: index)
        }
    }

    public func applyLayout() {
        gvlGraph.applyLayout()
    }
}
