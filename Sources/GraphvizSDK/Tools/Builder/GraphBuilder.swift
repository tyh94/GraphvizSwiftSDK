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
    private var ordering: GVOrdering?
    private var concentrate: Bool?
    private var style: GVNodeStyle?
    private var newrank: Bool?
    
    public init() {}
    
    public func build() throws -> Graph {
        let graph = try Graph(name: "graph_\(arc4random())", type: type)
        let gvGraph = graph.graph
        
        try nodeBuilders.forEach { builder in
            try graph.append(builder.build(graph: gvGraph))
        }
        try edgeBuilders.forEach { builder in
            try graph.append(builder.build(graph: gvGraph))
        }
        
        try subgraphBuilders.forEach { builder in
            try graph.append(builder.build(graph: gvGraph))
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
        if let ordering {
            graph.ordering = ordering
        }
        if let concentrate {
            graph.concentrate = concentrate
        }
        if let style {
            graph.style = style
        }
        if let newrank {
            graph.newrank = newrank
        }
        
        return graph
    }
}

extension GraphBuilder {
    @discardableResult
    public func node(_ builder: (NodeBuilder) -> NodeBuilder) -> NodeBuilder {
        let nodeBuilder = NodeBuilder()
        nodeBuilders.append(builder(nodeBuilder))
        return nodeBuilder
    }
    
    @discardableResult
    public func edge(
        source: NodeBuilder,
        targer: NodeBuilder,
        _ builder: (EdgeBuilder) -> EdgeBuilder
    ) -> EdgeBuilder {
        let edgeBuilder = EdgeBuilder(source: source, targer: targer)
        edgeBuilders.append(builder(edgeBuilder))
        return edgeBuilder
    }
    
    @discardableResult
    public func subgraph(_ builder: (SubgraphBuilder) -> SubgraphBuilder) -> SubgraphBuilder {
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
    
    @discardableResult
    public func with(ordering: GVOrdering) -> Self {
        self.ordering = ordering
        return self
    }
    
    @discardableResult
    public func with(concentrate: Bool) -> Self {
        self.concentrate = concentrate
        return self
    }
    
    @discardableResult
    public func with(style: GVNodeStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func with(newrank: Bool) -> Self {
        self.newrank = newrank
        return self
    }
}
