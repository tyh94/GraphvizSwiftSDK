//
//  Graph.swift
//  GraphLayout
//
//  Copyright © 2018 bakhtiyor.com.
//  MIT License
//

import UIKit

public class Graph {
    var gvlGraph: GVLGraph

    public private(set) var nodes = [Node]()
    public private(set) var edges = [Edge]()
    public var size: CGSize {
        gvlGraph.size
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
        let gvlNode = gvlGraph.addNode(label: label)
        let node = Node(gvlNode: gvlNode)
        nodes.append(node)
        return node
    }

    public func removeNode(node: Node) {
        guard nodes.count > 1 else { return }
        if let index = nodes.firstIndex(of: node) {
            for edge in edges {
                if edge.from == node || edge.to == node {
                    removeEdge(edge: edge)
                }
            }
            nodes.remove(at: index)
        }
    }

    public func addEdge(from: Node, to: Node) -> Edge {
        let gvlEdge = gvlGraph.addEdge(from: from.gvlNode, to: to.gvlNode)
        let edge = Edge(gvlEdge: gvlEdge, from: from, to: to)
        edges.append(edge)
        return edge
    }

    public func removeEdge(edge: Edge) {
        if let index = edges.firstIndex(of: edge) {
            edges.remove(at: index)
        }
    }
    
    public func createSubgraph() -> Subgraph {
        let gvlSubgraph = gvlGraph.addSubgraph()
        return Subgraph(gvlSubgraph: gvlSubgraph)
    }

    @MainActor public func applyLayout() {
        gvlGraph.applyLayout()
    }
}
