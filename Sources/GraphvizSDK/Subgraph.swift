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

public class Subgraph {
    private(set) var graph: GVGraph
    
    /// Subgraphs contained by the graph.
    public private(set) var subgraphs: [Subgraph] = []
    
    /// Nodes contained by the graph.
    public private(set) var nodes: [Node] = []

    /// Edges contained by the graph.
    public private(set) var edges: [Edge] = []
    
    @GVGraphvizProperty<GVGraphParameters, GVRank> public var rank: GVRank
    @GVGraphvizProperty<GVNodeParameters, GVNodeStyle> public var style: GVNodeStyle
    
    public init(
        name: String,
        parent: GVGraph
    ) {
        self.graph = agsubg(parent, cString(name), 1)!
        _rank = GVGraphvizProperty(key: .rank, defaultValue: .none, container: graph)
        _style = GVGraphvizProperty(key: .style, defaultValue: .none, container: graph)
    }
    
    public func append(_ subgraph: Subgraph) {
        subgraphs.append(subgraph)
    }
    
    public func append(_ node: @autoclosure () -> Node) {
        nodes.append(node())
    }

    public func append(_ edge: @autoclosure () -> Edge) {
        edges.append(edge())
    }
}
