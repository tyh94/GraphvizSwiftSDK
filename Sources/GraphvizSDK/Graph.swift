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

open class Graph {
    private(set) var graph: GVGraph
    let nodes: [Node]
    let edges: [Edge]
    public var size: CGSize {
        graph.size
    }
    
    @GVGraphvizProperty<GVGraphParameters, GVRank> public var rank: GVRank
    @GVGraphvizProperty<GVGraphParameters, GVParamValueSplines> public var splines: GVParamValueSplines
    @GVGraphvizProperty<GVGraphParameters, GVModelDirection> public var rankdir: GVModelDirection
    @GVGraphvizProperty<GVGraphParameters, GVParamValueOverlap> public var overlap: GVParamValueOverlap
    @GVGraphvizProperty<GVGraphParameters, String> public var fontname: String
    @GVGraphvizProperty<GVGraphParameters, Double> public var fontsize: Double
    
    init(
        _ graph: GVGraph,
        nodes: [Node],
        edges: [Edge]
    ) {
        self.graph = graph
        self.nodes = nodes
        self.edges = edges
        _rank = GVGraphvizProperty(key: .rank, defaultValue: .none, container: graph)
        _splines = GVGraphvizProperty(key: .splines, defaultValue: .none, container: graph)
        _rankdir = GVGraphvizProperty(key: .rankdir, defaultValue: .towardsTop, container: graph)
        _overlap = GVGraphvizProperty(key: .overlap, defaultValue: .retain, container: graph)
        _fontname = GVGraphvizProperty(key: .fontname, defaultValue: "Times-Roman", container: graph)
        _fontsize = GVGraphvizProperty(key: .fontsize, defaultValue: 14.0, container: graph)
    }
}
