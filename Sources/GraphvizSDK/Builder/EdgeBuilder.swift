//
//  EdgeBuilder.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 01.05.2025.
//

import Foundation

public final class EdgeBuilder {
    let source: NodeBuilder
    let targer: NodeBuilder
    
    var dir: GVEdgeParamDir?
    
    init(
        source: NodeBuilder,
        targer: NodeBuilder
    ) {
        self.source = source
        self.targer = targer
    }
    
    public func build(
        graph: GVGraph
    ) -> Edge {
        let edge = Edge(parent: graph, from: source.build(graph: graph), to: targer.build(graph: graph))
        if let dir {
            edge.dir = dir
        }
        return edge
    }
}

extension EdgeBuilder {
    @discardableResult
    public func with(dir: GVEdgeParamDir) -> Self {
        self.dir = dir
        return self
    }
}
