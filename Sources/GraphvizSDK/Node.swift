//
//  Node.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import UIKit
import CoreGraphics
import OSLog

public class Node: Equatable {
    // TODO: add image https://graphviz.org/docs/attrs/image/
    let node: GVNode
    
    public var borderColor: UIColor = UIColor.black // TODO: color https://graphviz.org/docs/attrs/color/
    public var textColor: UIColor = UIColor.black // TODO: fontcolor  https://graphviz.org/docs/attrs/fontcolor/
    
    @GVGraphvizProperty<GVNodeParameters, String> public var label: String
    @GVGraphvizProperty<GVNodeParameters, Int> public var fontSize: Int
    @GVGraphvizProperty<GVNodeParameters, Double> public var width: Double
    @GVGraphvizProperty<GVNodeParameters, Double> public var height: Double
    @GVGraphvizProperty<GVNodeParameters, GVNodeShape> public var shape: GVNodeShape
    @GVGraphvizProperty<GVNodeParameters, GVNodeStyle> public var style: GVNodeStyle
    @GVGraphvizProperty<GVNodeParameters, Bool> public var fixedsize: Bool
    @GVGraphvizProperty<GVNodeParameters, Double> public var fontsize: Double
    @GVGraphvizProperty<GVNodeParameters, String> public var fontname: String
    @GVGraphvizProperty<GVNodeParameters, GVLabelLocation> public var labelloc: GVLabelLocation
    @GVGraphvizProperty<GVNodeParameters, Double> public var margin: Double
    @GVGraphvizProperty<GVNodeParameters, Double> public var penwidth: Double
    
    init(node: GVNode) {
        self.node = node
        _label = GVGraphvizProperty(key: GVNodeParameters.label, defaultValue: "", container: node)
        _fontSize = GVGraphvizProperty(key: GVNodeParameters.fontsize, defaultValue: 14, container: node)
        _width = GVGraphvizProperty(key: GVNodeParameters.width, defaultValue: 1.0, container: node)
        _height = GVGraphvizProperty(key: GVNodeParameters.height, defaultValue: 1.0, container: node)
        _shape = GVGraphvizProperty(key: GVNodeParameters.shape, defaultValue: .ellipse, container: node)
        _style = GVGraphvizProperty(key: GVNodeParameters.style, defaultValue: .none, container: node)
        _fixedsize = GVGraphvizProperty(key: GVNodeParameters.fixedsize, defaultValue: false, container: node)
        _fontsize = GVGraphvizProperty(key: GVNodeParameters.fontsize, defaultValue: 14.0, container: node)
        _fontname = GVGraphvizProperty(key: GVNodeParameters.fontname, defaultValue: "Times-Roman", container: node)
        _labelloc = GVGraphvizProperty(key: GVNodeParameters.labelloc, defaultValue: .c, container: node)
        _margin = GVGraphvizProperty(key: GVNodeParameters.margin, defaultValue: 0.0, container: node)
        _penwidth = GVGraphvizProperty(key: GVNodeParameters.penwidth, defaultValue: 1.0, container: node)
    }
    
    convenience init(parent: GVGraph, label: String) {
        let node = agnode(parent, cString(label), 1)
        self.init(node: node!)
        self.label = label
    }
    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
    }
}
