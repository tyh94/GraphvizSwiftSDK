//
//  GraphBuilder.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 01.05.2025.
//

import Foundation
@preconcurrency import CGraphvizSDK

public final class GraphBuilder {
    private var nodeBuilders: [NodeBuilder] = []
    private var edgeBuilders: [EdgeBuilder] = []
    private var subgraphBuilders: [SubgraphBuilder] = []
    
    private var type: GVGraphType = .nonStrictDirected
    private var splines: GVParamValueSplines?
    private var rankdir: GVModelDirection?
    private var overlap: GVParamValueOverlap?
    
    public init() {}
    
    public func build() -> Graph {
        let name = "graph_\(arc4random())"
        let cName = cString(name)
        let gvGraph = agopen(cName, type.graphvizValue, nil)!
        
        var nodes: [Node] = []
        var edges: [Edge] = []
        
        nodeBuilders.forEach { builder in
            nodes.append(builder.build(graph: gvGraph))
        }
        edgeBuilders.forEach { builder in
            edges.append(builder.build(graph: gvGraph))
        }
        
        subgraphBuilders.forEach { builder in
            let subgraph = builder.build(graph: gvGraph)
            builder.nodeBuilders.forEach { builder in
                nodes.append(builder.build(graph: subgraph.graph))
            }
            builder.edgeBuilders.forEach { builder in
                edges.append(builder.build(graph: subgraph.graph))
            }
        }
        
        let graph = Graph(gvGraph, nodes: nodes, edges: edges)
        
        if let splines {
            graph.splines = splines
        }
        if let rankdir {
            graph.rankdir = rankdir
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
}
