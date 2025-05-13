//
//  Subgraph.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation
import CoreGraphics
import OSLog

public struct Subgraph {
    private(set) var graph: GVGraph
    
    /// Nodes contained by the graph.
    public private(set) var nodes: [Node] = []

    /// Edges contained by the graph.
    public private(set) var edges: [Edge] = []
    
    @GVGraphvizProperty<GVGraphParameters, GVRank> public var rank: GVRank
    
    public init(
        name: String,
        parent: GVGraph
    ) {
        self.graph = agsubg(parent, cString(name), 1)!
        _rank = GVGraphvizProperty(key: .rank, defaultValue: .none, container: graph)
    }
    
    public mutating func append(_ node: @autoclosure () -> Node) {
        nodes.append(node())
    }

    public mutating func append(_ edge: @autoclosure () -> Edge) {
        edges.append(edge())
    }
}
