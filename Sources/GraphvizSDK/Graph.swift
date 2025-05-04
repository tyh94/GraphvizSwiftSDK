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
    
    init(
        _ graph: GVGraph,
        nodes: [Node],
        edges: [Edge]
    ) {
        self.graph = graph
        self.nodes = nodes
        self.edges = edges
        _rank = GVGraphvizProperty(key: GVGraphParameters.rank, defaultValue: .none, container: graph)
        _splines = GVGraphvizProperty(key: GVGraphParameters.splines, defaultValue: .none, container: graph)
        _rankdir = GVGraphvizProperty(key: GVGraphParameters.rankdir, defaultValue: .towardsTop, container: graph)
        _overlap = GVGraphvizProperty(key: .overlap, defaultValue: .retain, container: graph)
    }
    
    // MARK: - Layout Operations
    
    public func log() {
//        guard gvLayout(context, graph, "dot") == 0 else { return }
//        
//        var data: CHAR?
//        var len: size_t = 0
//        gvRenderData(context, graph, "dot", &data, &len)
//        if let data {
//            Logger.graphviz.debug(message: "==========================")
//            Logger.graphviz.debug(message: String(cString: data))
//            Logger.graphviz.debug(message: "==========================")
//        }
    }
}
