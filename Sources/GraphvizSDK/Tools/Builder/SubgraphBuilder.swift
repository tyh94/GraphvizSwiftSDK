//
//  SubgraphBuilder.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 01.05.2025.
//

import Foundation

public final class SubgraphBuilder: GraphBuilderProtocol {
    private(set) var nodeBuilders: [NodeBuilder] = []
    private(set) var edgeBuilders: [EdgeBuilder] = []
    private var name: String?
    private var rank: GVRank?
    
    public func build(graph: GVGraph) -> Subgraph {
        var graph = Subgraph(name: name ?? "subgraph_\(arc4random())", parent: graph)
        let gvGraph = graph.graph
        nodeBuilders.forEach { builder in
            graph.append(builder.build(graph: gvGraph))
        }
        edgeBuilders.forEach { builder in
            graph.append(builder.build(graph: gvGraph))
        }
        if let rank {
            graph.rank = rank
        }
        return graph
    }
}

extension SubgraphBuilder {
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
    public func with(name: String) -> Self {
        self.name = name
        return self
    }
    
    @discardableResult
    public func with(rank: GVRank) -> Self {
        self.rank = rank
        return self
    }
}
