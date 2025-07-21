//
//  GraphBuilder.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 01.05.2025.
//

import Foundation
@preconcurrency import CGraphvizSDK

public final class GraphBuilder: GraphBuilderProtocol {
    private(set) var nodeBuilders: [NodeBuilder] = []
    private(set) var edgeBuilders: [EdgeBuilder] = []
    private(set) var subgraphBuilders: [SubgraphBuilder] = []
    
    private var type: GVGraphType = .nonStrictDirected
    private var splines: GVParamValueSplines?
    private var rankdir: GVModelDirection?
    private var overlap: GVParamValueOverlap?
    private var fontsize: Double?
    private var fontname: String?
    private var ranksep: Double?
    private var nodesep: Double?
    
    public init() {}
    
    public func build() -> Graph {
        var graph = Graph(name: "graph_\(arc4random())", type: type)
        let gvGraph = graph.graph
        
        nodeBuilders.forEach { builder in
            graph.append(builder.build(graph: gvGraph))
        }
        edgeBuilders.forEach { builder in
            graph.append(builder.build(graph: gvGraph))
        }
        
        subgraphBuilders.forEach { builder in
            graph.append(builder.build(graph: gvGraph))
        }
        
        if let splines {
            graph.splines = splines
        }
        if let rankdir {
            graph.rankdir = rankdir
        }
        if let fontname {
            graph.fontname = fontname
        }
        if let fontsize {
            graph.fontsize = fontsize
        }
        if let ranksep {
            graph.ranksep = ranksep
        }
        if let nodesep {
            graph.nodesep = nodesep
        }
        
        return graph
    }
}

extension GraphBuilder {
    @discardableResult
    public func node(_ builder: @escaping (NodeBuilder) -> NodeBuilder) -> NodeBuilder {
        let nodeBuilder = NodeBuilder()
        nodeBuilders.append(builder(nodeBuilder))
        return nodeBuilder
    }
    
    @discardableResult
    public func edge(
        source: NodeBuilder,
        targer: NodeBuilder,
        _ builder: @escaping (EdgeBuilder) -> EdgeBuilder
    ) -> EdgeBuilder {
        let edgeBuilder = EdgeBuilder(source: source, targer: targer)
        edgeBuilders.append(builder(edgeBuilder))
        return edgeBuilder
    }
    
    @discardableResult
    public func subgraph(_ builder: @escaping (SubgraphBuilder) -> SubgraphBuilder) -> SubgraphBuilder {
        let subgraphBuilder = SubgraphBuilder()
        subgraphBuilders.append(builder(subgraphBuilder))
        return subgraphBuilder
    }
    
    @discardableResult
    public func with(type: GVGraphType) -> Self {
        self.type = type
        return self
    }
    
    @discardableResult
    public func with(splines: GVParamValueSplines) -> Self {
        self.splines = splines
        return self
    }
    
    @discardableResult
    public func with(rankdir: GVModelDirection) -> Self {
        self.rankdir = rankdir
        return self
    }
    
    @discardableResult
    public func with(overlap: GVParamValueOverlap) -> Self {
        self.overlap = overlap
        return self
    }
    
    @discardableResult
    public func with(fontname: String) -> Self {
        self.fontname = fontname
        return self
    }
    
    @discardableResult
    public func with(fontsize: Double) -> Self {
        self.fontsize = fontsize
        return self
    }
    
    @discardableResult
    public func with(ranksep: Double) -> Self {
        self.ranksep = ranksep
        return self
    }
    
    @discardableResult
    public func with(nodesep: Double) -> Self {
        self.nodesep = nodesep
        return self
    }
}
