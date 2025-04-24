//
//  Node.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

import UIKit

public class Node: Equatable {
    // TODO: add image https://graphviz.org/docs/attrs/image/
    let gvlNode: GVLNode

    public var label: String {
        get { gvlNode.label }
        set { gvlNode.label = newValue }
    }
    public var color: UIColor = UIColor.white
    public var highlihtedColor: UIColor = UIColor.lightGray
    public var borderColor: UIColor = UIColor.black // TODO: color https://graphviz.org/docs/attrs/color/
    public var borderWidth: Float = 1.0 // TODO: penwidth https://graphviz.org/docs/attrs/penwidth/
    public var textColor: UIColor = UIColor.black // TODO: fontcolor  https://graphviz.org/docs/attrs/fontcolor/
    public var fontSize: Int = 14 {
        didSet {
            setAttribute(name: .fontsize, value: fontSize.description)
        }
    }
    public var shape: GVNodeShape = .ellipse {
        didSet {
            setAttribute(name: .shape, value: shape.rawValue)
        }
    }
    public var width: Double = 1.0 {
        didSet {
            setAttribute(name: .width, value: width.description)
        }
    }
    public var height: Double = 1.0 {
        didSet {
            setAttribute(name: .height, value: height.description)
        }
    }
    
    public var style: GVNodeStyle {
        get { GVNodeStyle(rawValue: getAttribute(name: .style)) ?? .none }
        set {
            setAttribute(name: .style, value: newValue.rawValue)
        }
    }
    
    public init(gvlNode: GVLNode) {
        self.gvlNode = gvlNode
    }
    
    public func setBaseParameters(params: [GVNodeParameters: String]) {
        params.forEach { setAttribute(name: $0.key, value: $0.value) }
    }

    public func getAttribute(name: GVNodeParameters) -> String {
        gvlNode.getAttribute(forKey: name)
    }

    func setAttribute(name: GVNodeParameters, value: String) {
        gvlNode.setAttribute(value, forKey: name)
    }

    public func frame() -> CGRect {
        gvlNode.frame
    }

    public func bounds() -> CGRect {
        gvlNode.bounds
    }

    public func path() -> UIBezierPath {
        gvlNode.bezierPath
    }

    public static func == (lhs: Node, rhs: Node) -> Bool {
        lhs === rhs
    }
}
