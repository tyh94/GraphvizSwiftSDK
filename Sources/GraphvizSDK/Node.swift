//
//  Node.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import SwiftUI
import CoreGraphics
import OSLog

public class Node {
    // TODO: add image https://graphviz.org/docs/attrs/image/
    let node: GVNode
    let name: String
    
    public var borderColor: Color = .black
    public var textColor: Color = .black
    
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
    @GVGraphvizProperty<GVNodeParameters, GVColor> public var color: GVColor
    @GVGraphvizProperty<GVNodeParameters, GVColor> public var fontcolor: GVColor
    @GVGraphvizProperty<GVNodeParameters, String> public var image: String
    @GVGraphvizProperty<GVNodeParameters, GVImagePosition> public var imagePosition: GVImagePosition
    @GVGraphvizProperty<GVNodeParameters, GVImageScale> public var imageScale: GVImageScale
    
    init(node: GVNode, name: String) {
        self.node = node
        self.name = name
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
        _color = GVGraphvizProperty(key: .color, defaultValue: .named(.black), container: node)
        _fontcolor = GVGraphvizProperty(key: .fontcolor, defaultValue: .named(.black), container: node)
        _image = GVGraphvizProperty(key: .image, defaultValue: "", container: node)
        _imagePosition = GVGraphvizProperty(key: .imagepos, defaultValue: .middleCentered, container: node)
        _imageScale = GVGraphvizProperty(key: .imagescale, defaultValue: .off, container: node)
    }
    
    convenience init(parent: GVGraph, name: String) {
        let node = agnode(parent, cString(name), 1)
        self.init(node: node!, name: name)
    }
}

extension GVColor {
    var toColor: Color {
        switch self {
        case .transparent:
            return .black
        case .named(let name):
            return .black
        case .rgb(red: let red, green: let green, blue: let blue):
            return Color(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
        case .rgba(red: let red, green: let green, blue: let blue, alpha: let alpha):
            return Color(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255, opacity: Double(alpha) / 255)
        case .hsv(hue: let hue, saturation: let saturation, value: let value):
            return Color(hue: hue, saturation: saturation, brightness: value)
        case .custom(_):
            return .black
        }
    }
}
