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
    private let subgraph: GVGraph
    public var nodes: [GVLNode] = []
    public var edges: [GVLEdge] = []
    
    public init(
        name: String,
        parent: GVGraph
    ) {
        self.subgraph = agsubg(parent, cString(name), 1)
    }
    
    public func setAttribute(_ value: String, forKey key: String) {
        agsafeset(subgraph, cString(key), cString(value), "")
    }
    
    public func getAttribute(forKey key: String) -> String {
        guard let cValue = agget(subgraph, cString(key)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
    public func addNode(label: String) -> GVLNode {
        let node = GVLNode(parent: subgraph, label: label)
        nodes.append(node)
        return node
    }
    
    public func addEdge(from source: GVLNode, to target: GVLNode) -> GVLEdge {
        let edge = GVLEdge(parent: subgraph, from: source, to: target)
        edges.append(edge)
        return edge
    }
    
    public func setRank(_ rank: RankType) {
        setAttribute(rank.rawValue, forKey: "rank")
    }
}
