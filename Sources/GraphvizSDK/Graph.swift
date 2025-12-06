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

public class Graph {
    public enum Error: Swift.Error {
        case invalidGVGraph
    }
    
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
    // Note: fdp, neato, sfdp, circo, twopi only.
    @GVGraphvizProperty<GVGraphParameters, GVParamValueOverlap> public var overlap: GVParamValueOverlap
    @GVGraphvizProperty<GVGraphParameters, String> public var fontname: String
    @GVGraphvizProperty<GVGraphParameters, Double> public var fontsize: Double
    @GVGraphvizProperty<GVGraphParameters, Double> public var ranksep: Double
    @GVGraphvizProperty<GVGraphParameters, Double> public var nodesep: Double
    @GVGraphvizProperty<GVGraphParameters, GVOrdering> public var ordering: GVOrdering
    @GVGraphvizProperty<GVGraphParameters, Bool> public var concentrate: Bool
    @GVGraphvizProperty<GVNodeParameters, GVNodeStyle> public var style: GVNodeStyle
    @GVGraphvizProperty<GVGraphParameters, Bool> public var newrank: Bool
    @GVGraphvizProperty<GVGraphParameters, Bool> public var compound: Bool
    
    init(
        _ graph: GVGraph
    ) {
        self.graph = graph
        _splines = GVGraphvizProperty(key: .splines, defaultValue: .none, container: graph)
        _rankdir = GVGraphvizProperty(key: .rankdir, defaultValue: .towardsTop, container: graph)
        _overlap = GVGraphvizProperty(key: .overlap, defaultValue: .retain, container: graph)
        _fontname = GVGraphvizProperty(key: .fontname, defaultValue: "Times-Roman", container: graph)
        _fontsize = GVGraphvizProperty(key: .fontsize, defaultValue: 14.0, container: graph)
        _ranksep = GVGraphvizProperty(key: .ranksep, defaultValue: 0.5, container: graph)
        _nodesep = GVGraphvizProperty(key: .nodesep, defaultValue: 0.25, container: graph)
        _ordering = GVGraphvizProperty(key: .ordering, defaultValue: .none, container: graph)
        _concentrate = GVGraphvizProperty(key: .concentrate, defaultValue: false, container: graph)
        _style = GVGraphvizProperty(key: .style, defaultValue: .none, container: graph)
        _newrank = GVGraphvizProperty(key: .newrank, defaultValue: false, container: graph)
        _compound = GVGraphvizProperty(key: .compound, defaultValue: false, container: graph)
    }
    
    convenience init(name: String, type: GVGraphType) throws {
        let cName = cString(name)
        guard let gvGraph = agopen(cName, type.graphvizValue, nil) else {
            throw Error.invalidGVGraph
        }
        self.init(gvGraph)
    }
    
    deinit {
        agclose(graph)
    }
    
    public func append(_ subgraph: Subgraph) {
        subgraphs.append(subgraph)
    }

    public func append<S>(contentsOf subgraphs: S) where S.Element == Subgraph, S: Sequence {
        for subgraph in subgraphs {
            append(subgraph)
        }
    }

    public func append(_ node: Node) {
        nodes.append(node)
    }

    public func append<S>(contentsOf nodes: S) where S.Element == Node, S: Sequence {
        for node in nodes {
            append(node)
        }
    }

    public func append(_ edge:Edge) {
        edges.append(edge)
    }

    public func append<S>(contentsOf edges: S) where S.Element == Edge, S: Sequence {
        for edge in edges {
            append(edge)
        }
    }
}
