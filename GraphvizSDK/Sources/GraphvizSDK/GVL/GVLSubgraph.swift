//
//  GVLSubgraph.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

public enum RankType: String {
    case same
    case min
    case source
}

public class GVLSubgraph {
    private let subgraph: UnsafeMutablePointer<Agraph_t>
    private let parentGraph: UnsafeMutablePointer<Agraph_t>
    
    public init(parent: UnsafeMutablePointer<Agraph_t>) {
        let cName = strdup("graph_\(arc4random())")
        self.parentGraph = parent
        self.subgraph = agsubg(parent, cName, 1)
//        free(cName)
    }
    
    public func setAttribute(_ value: String, forKey key: String) {
        agsafeset(subgraph, strdup(key), strdup(value), "")
    }
    
    public func getAttribute(forKey key: String) -> String {
        guard let cValue = agget(subgraph, strdup(key)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
    public func addNode(_ node: GVLNode) {
        let node = agsubnode(subgraph, node.node, 1)
        if node == nil {
            fatalError()
        }
    }
    
    public func addEdge(_ edge: GVLEdge) {
        let edge = agsubedge(subgraph, edge.edge, 1)
        if edge == nil {
            fatalError()
        }
    }
    
    public func addNode(label: String) -> GVLNode {
        let node = GVLNode(parent: subgraph, label: label)
        return node
    }
    
    public func addEdge(from source: GVLNode, to target: GVLNode) -> GVLEdge {
        let edge = GVLEdge(parent: subgraph, from: source, to: target)
        return edge
    }
    
    public func setRank(_ rank: RankType) {
        setAttribute(rank.rawValue, forKey: "rank")
    }
    
    deinit {
        agclose(subgraph)
    }
}
