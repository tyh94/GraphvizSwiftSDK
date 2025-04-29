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
    
    public var nodesDraw: [Node] {
        nodes + subgraphs.flatMap { $0.nodes }
    }
    
    public var edgesDraw: [Edge] {
        edges + subgraphs.flatMap { $0.edges }
    }

    private var nodes = [Node]()
    private var edges = [Edge]()
    private var subgraphs = [Subgraph]()
    public var size: CGSize {
        gvlGraph.size
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
    
    public func createSubgraph(name: String) -> Subgraph {
        let gvlSubgraph = gvlGraph.addSubgraph(name: name)
        let subgraph = Subgraph(gvlSubgraph: gvlSubgraph)
        subgraphs.append(subgraph)
        return subgraph
    }
    
    public func setSameRank(nodes: [String]) {
        gvlGraph.setSameRank(nodes: nodes)
    }

    @MainActor public func applyLayout() {
        gvlGraph.applyLayout()
    }
}
