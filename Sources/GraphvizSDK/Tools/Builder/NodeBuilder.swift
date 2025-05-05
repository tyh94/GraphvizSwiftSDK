//
//  NodeBuilder.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 01.05.2025.
//

import Foundation

public final class NodeBuilder {
    private var name: String?
    
    private var width: Double?
    private var height: Double?
    private var shape: GVNodeShape?
    private var style: GVNodeStyle?
    private var label: String?
    private var fixedsize: Bool?
    private var fontsize: Double?
    private var fontname: String? // "Times-Roman" https://graphviz.org/docs/attrs/fontname/
    private var labelloc: GVLabelLocation? // https://graphviz.org/docs/attrs/labelloc/
    private var margin: Double? //https://graphviz.org/docs/attrs/margin/
    private var penwidth: Double?
    
    public func build(graph: GVGraph) -> Node {
        let node = Node(parent: graph, label: name ?? label ?? "node_\(arc4random())")
        if let width {
            node.width = width
        }
        if let height {
            node.height = height
        }
        if let shape {
            node.shape = shape
        }
        if let style {
            node.style = style
        }
        if let label {
            node.label = label
        }
        if let fixedsize {
            node.fixedsize = fixedsize
        }
        if let fontsize {
            node.fontsize = fontsize
        }
        if let fontname {
            node.fontname = fontname
        }
        if let labelloc {
            node.labelloc = labelloc
        }
        if let margin {
            node.margin = margin
        }
        if let penwidth {
            node.penwidth = penwidth
        }
        return node
    }
}

extension NodeBuilder {
    @discardableResult
    public func with(width: Double) -> Self {
        self.width = width
        return self
    }
    
    @discardableResult
    public func with(height: Double) -> Self {
        self.height = height
        return self
    }
    
    @discardableResult
    public func with(shape: GVNodeShape) -> Self {
        self.shape = shape
        return self
    }
    
    @discardableResult
    public func with(style: GVNodeStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func with(name: String) -> Self {
        self.name = name
        return self
    }
    
    @discardableResult
    public func with(label: String) -> Self {
        self.label = label
        return self
    }
    
    @discardableResult
    public func with(fixedsize: Bool) -> Self {
        self.fixedsize = fixedsize
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
    public func with(labelloc: GVLabelLocation) -> Self {
        self.labelloc = labelloc
        return self
    }
    
    @discardableResult
    public func with(margin: Double) -> Self {
        self.margin = margin
        return self
    }
    
    @discardableResult
    public func with(penwidth: Double) -> Self {
        self.penwidth = penwidth
        return self
    }
}
