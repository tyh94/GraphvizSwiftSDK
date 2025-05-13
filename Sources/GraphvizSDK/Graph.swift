//
//  Graph.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation
import CoreGraphics
import OSLog

public struct Graph {
    private(set) var graph: GVGraph
    
    /// Subgraphs contained by the graph.
    public private(set) var subgraphs: [Subgraph] = []

    /// Nodes contained by the graph.
    public private(set) var nodes: [Node] = []

    /// Edges contained by the graph.
    public private(set) var edges: [Edge] = []
    
    public var size: CGSize {
        graph.size
    }
    
    @GVGraphvizProperty<GVGraphParameters, GVParamValueSplines> public var splines: GVParamValueSplines
    @GVGraphvizProperty<GVGraphParameters, GVModelDirection> public var rankdir: GVModelDirection
    @GVGraphvizProperty<GVGraphParameters, GVParamValueOverlap> public var overlap: GVParamValueOverlap
    @GVGraphvizProperty<GVGraphParameters, String> public var fontname: String
    @GVGraphvizProperty<GVGraphParameters, Double> public var fontsize: Double
    
    init(
        _ graph: GVGraph
    ) {
        self.graph = graph
        _splines = GVGraphvizProperty(key: .splines, defaultValue: .none, container: graph)
        _rankdir = GVGraphvizProperty(key: .rankdir, defaultValue: .towardsTop, container: graph)
        _overlap = GVGraphvizProperty(key: .overlap, defaultValue: .retain, container: graph)
        _fontname = GVGraphvizProperty(key: .fontname, defaultValue: "Times-Roman", container: graph)
        _fontsize = GVGraphvizProperty(key: .fontsize, defaultValue: 14.0, container: graph)
    }
    
    init(name: String, type: GVGraphType) {
        let name = "graph_\(arc4random())"
        let cName = cString(name)
        let gvGraph = agopen(cName, type.graphvizValue, nil)!
        self.init(gvGraph)
    }
    
    public mutating func append(_ subgraph: Subgraph) {
        subgraphs.append(subgraph)
    }

    public mutating func append<S>(contentsOf subgraphs: S) where S.Element == Subgraph, S: Sequence {
        for subgraph in subgraphs {
            self.subgraphs.append(subgraph)
        }
    }

    public mutating func append(_ node: Node) {
        nodes.append(node)
    }

    public mutating func append<S>(contentsOf nodes: S) where S.Element == Node, S: Sequence {
        for node in nodes {
            self.nodes.append(node)
        }
    }

    public mutating func append(_ edge:Edge) {
        edges.append(edge)
    }

    public mutating func append<S>(contentsOf edges: S) where S.Element == Edge, S: Sequence {
        for edge in edges {
            self.edges.append(edge)
        }
    }
}
