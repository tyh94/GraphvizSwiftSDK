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
    public var splines: GVParamValueSplines = .ortho {
        didSet {
            gvlGraph.setAttribute(splines.rawValue, forKey: .splines)
        }
    }

    public convenience init() {
        self.init(GVLGraph())
    }
    
    public init(_ gvlGraph: GVLGraph) {
        self.gvlGraph = gvlGraph
    }
    
    public func setBaseParameters(params: [GVGraphParameters: String]) {
        params.forEach { gvlGraph.setAttribute($0.value, forKey: $0.key) }
    }
    
    public convenience init(str: String) {
        self.init(GVLGraph(str: str))
        fillNodesAndEdges()
    }
    
    func fillNodesAndEdges() {
        nodes = gvlGraph.nodes.map(Node.init(gvlNode:))
        edges = gvlGraph.edges.map(Edge.init(gvlEdge:))
    }

    // TODO: Add name and label. if name nil, use label in both
    public func addNode(_ label: String) -> Node {
        let gvlNode = gvlGraph.addNode(label: label)
        let node = Node(gvlNode: gvlNode)
        nodes.append(node)
        return node
    }

    public func addEdge(from: Node, to: Node) -> Edge {
        let gvlEdge = gvlGraph.addEdge(from: from.gvlNode, to: to.gvlNode)
        let edge = Edge(gvlEdge: gvlEdge)
        edges.append(edge)
        return edge
    }
    
    public func createSubgraph() -> Subgraph {
        let gvlSubgraph = gvlGraph.addSubgraph()
        return Subgraph(gvlSubgraph: gvlSubgraph)
    }
    
    public func setSameRank(nodes: [String]) {
        gvlGraph.setSameRank(nodes: nodes)
    }

    @MainActor public func applyLayout() {
        gvlGraph.applyLayout()
    }
}
