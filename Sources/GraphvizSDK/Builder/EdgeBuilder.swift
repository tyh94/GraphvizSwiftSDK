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
    
    private var dir: GVEdgeParamDir?
    private var arrowheadType: GVEdgeEnding?
    private var arrowtailType: GVEdgeEnding?
    private var weight: Float?
    private var minlen: Int?
    private var penwidth: Double?
    
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
        if let minlen {
            edge.minlen = minlen
        }
        if let penwidth {
            edge.penwidth = penwidth
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
    
    @discardableResult
    public func with(minlen: Int) -> Self {
        self.minlen = minlen
        return self
    }
    
    @discardableResult
    public func with(arrowheadType: GVEdgeEnding) -> Self {
        self.arrowheadType = arrowheadType
        return self
    }
    
    @discardableResult
    public func with(arrowtailType: GVEdgeEnding) -> Self {
        self.arrowtailType = arrowtailType
        return self
    }
    
    @discardableResult
    public func with(weight: Float) -> Self {
        self.weight = weight
        return self
    }
    
    @discardableResult
    public func with(penwidth: Double) -> Self {
        self.penwidth = penwidth
        return self
    }
}
