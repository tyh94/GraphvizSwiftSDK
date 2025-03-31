//
//  Subgraph.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//


import UIKit

public class Subgraph {
    var gvlSubgraph: GVLSubgraph
    
    public init(gvlSubgraph: GVLSubgraph) {
        self.gvlSubgraph = gvlSubgraph
    }
    
    public func getAttribute(name: String) -> String? {
        gvlSubgraph.getAttribute(forKey: name)
    }

    public func setAttribute(name: String, value: String) {
        gvlSubgraph.setAttribute(value, forKey: name)
    }
    
    public func add(node: Node) {
        gvlSubgraph.addNode(node.gvlNode)
    }
    
    public func addNode(_ label: String) -> Node {
        let gvlNode = gvlSubgraph.addNode(label: label)
        let node = Node(gvlNode: gvlNode)
        return node
    }
    
    public func addEdge(from: Node, to: Node) -> Edge {
        let gvlEdge = gvlSubgraph.addEdge(from: from.gvlNode, to: to.gvlNode)
        let edge = Edge(gvlEdge: gvlEdge, from: from, to: to)
        return edge
    }
    
    public func setRank(_ rank: RankType) {
        gvlSubgraph.setRank(rank)
    }
}
