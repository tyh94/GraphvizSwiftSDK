//
//  EdgeBuilder.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 01.05.2025.
//

import Foundation
import SwiftUI

public final class EdgeBuilder {
    let source: NodeBuilder
    let targer: NodeBuilder
    
    private var dir: GVEdgeParamDir?
    private var arrowheadType: GVEdgeEnding?
    private var arrowtailType: GVEdgeEnding?
    private var weight: Float?
    private var minlen: Int?
    private var len: Double?
    private var penwidth: Double?
    private var fontsize: Double?
    private var fontname: String?
    private var color: Color?
    private var style: GVEdgeStyle?
    private var constraint: Bool?
    private var tailport: GVEdgePortPos?
    private var headport: GVEdgePortPos?
    
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
        if let arrowheadType {
            edge.arrowheadType = arrowheadType
        }
        if let arrowtailType {
            edge.arrowtailType = arrowtailType
        }
        if let weight {
            edge.weight = weight
        }
        if let len {
            edge.len = len
        }
        if let minlen {
            edge.minlen = minlen
        }
        if let penwidth {
            edge.penwidth = penwidth
        }
        if let fontsize {
            edge.fontsize = fontsize
        }
        if let fontname {
            edge.fontname = fontname
        }
        if let color {
            edge.color = color
        }
        if let style {
            edge.style = style
        }
        if let constraint {
            edge.constraint = constraint
        }
        if let tailport {
            edge.tailport = tailport
        }
        if let headport {
            edge.headport = headport
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
    public func with(len: Double) -> Self {
        self.len = len
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
    
    @discardableResult
    public func with(fontsize: Double) -> Self {
        self.fontsize = fontsize
        return self
    }
    
    @discardableResult
    public func with(fontname: String) -> Self {
        self.fontname = fontname
        return self
    }
    
    @discardableResult
    public func with(color: Color) -> Self {
        self.color = color
        return self
    }
    
    @discardableResult
    public func with(style: GVEdgeStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func with(constraint: Bool) -> Self {
        self.constraint = constraint
        return self
    }
    
    @discardableResult
    public func with(tailport: GVEdgePortPos) -> Self {
        self.tailport = tailport
        return self
    }
    
    @discardableResult
    public func with(headport: GVEdgePortPos) -> Self {
        self.headport = headport
        return self
    }
}
