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

public class Node {
    // TODO: add image https://graphviz.org/docs/attrs/image/
    let node: GVNode
    
    public var borderColor: UIColor = UIColor.black // TODO: color https://graphviz.org/docs/attrs/color/
    public var textColor: UIColor = UIColor.black // TODO: fontcolor  https://graphviz.org/docs/attrs/fontcolor/
    
    @GVGraphvizProperty<GVNodeParameters, String> public var label: String
    @GVGraphvizProperty<GVNodeParameters, Double> public var fontSize: Double
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
        _label = GVGraphvizProperty(key: .label, defaultValue: "", container: node)
        _fontSize = GVGraphvizProperty(key: .fontsize, defaultValue: 14, container: node)
        _width = GVGraphvizProperty(key: .width, defaultValue: 1.0, container: node)
        _height = GVGraphvizProperty(key: .height, defaultValue: 1.0, container: node)
        _shape = GVGraphvizProperty(key: .shape, defaultValue: .ellipse, container: node)
        _style = GVGraphvizProperty(key: .style, defaultValue: .none, container: node)
        _fixedsize = GVGraphvizProperty(key: .fixedsize, defaultValue: false, container: node)
        _fontsize = GVGraphvizProperty(key: .fontsize, defaultValue: 14.0, container: node)
        _fontname = GVGraphvizProperty(key: .fontname, defaultValue: "Times-Roman", container: node)
        _labelloc = GVGraphvizProperty(key: .labelloc, defaultValue: .c, container: node)
        _margin = GVGraphvizProperty(key: .margin, defaultValue: 0.0, container: node)
        _penwidth = GVGraphvizProperty(key: .penwidth, defaultValue: 1.0, container: node)
    }
    
    convenience init(parent: GVGraph, label: String) {
        let node = agnode(parent, cString(label), 1)
        self.init(node: node!)
        self.label = label
    }
}
