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
    private(set) var subgraphBuilders: [SubgraphBuilder] = []
    private var name: String?
    private var rank: GVRank?
    private var style: GVNodeStyle?
    
    public func build(graph: GVGraph) throws -> Subgraph {
        let graph = try Subgraph(name: name ?? "subgraph_\(arc4random())", parent: graph)
        let gvGraph = graph.graph
        for builder in nodeBuilders {
            let node = try builder.build(graph: gvGraph)
            graph.append(node)
        }
        for builder in edgeBuilders {
            let edge = try builder.build(graph: gvGraph)
            graph.append(edge)
        }
        for builder in subgraphBuilders {
            let subgraph = try builder.build(graph: gvGraph)
            graph.append(subgraph)
        }
        if let rank {
            graph.rank = rank
        }
        if let style {
            graph.style = style
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
    public func subgraph(_ builder: (SubgraphBuilder) -> SubgraphBuilder) -> SubgraphBuilder {
        let subgraphBuilder = SubgraphBuilder()
        subgraphBuilders.append(builder(subgraphBuilder))
        return subgraphBuilder
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
    
    @discardableResult
    public func with(style: GVNodeStyle) -> Self {
        self.style = style
        return self
    }
}
