//
//  Edge.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import SwiftUI
import CoreGraphics
import OSLog

public class Edge {
    public enum Error: Swift.Error {
        case invalidGVEdge
    }
    
    let edge: GVEdge
    public var color: Color = .black
    
    @GVGraphvizProperty<GVEdgeParameters, Float> public var weight: Float
    @GVGraphvizProperty<GVEdgeParameters, GVEdgeEnding> public var arrowheadType: GVEdgeEnding
    @GVGraphvizProperty<GVEdgeParameters, GVEdgeEnding> public var arrowtailType: GVEdgeEnding
    @GVGraphvizProperty<GVEdgeParameters, GVEdgeParamDir> public var dir: GVEdgeParamDir
    @GVGraphvizProperty<GVEdgeParameters, Double> public var len: Double
    @GVGraphvizProperty<GVEdgeParameters, Int> public var minlen: Int
    @GVGraphvizProperty<GVEdgeParameters, Double> public var penwidth: Double
    @GVGraphvizProperty<GVEdgeParameters, Double> public var fontsize: Double
    @GVGraphvizProperty<GVEdgeParameters, String> public var fontname: String
    @GVGraphvizProperty<GVEdgeParameters, GVEdgeStyle> public var style: GVEdgeStyle
    @GVGraphvizProperty<GVEdgeParameters, Bool> public var constraint: Bool
    @GVGraphvizProperty<GVEdgeParameters, GVEdgePortPos> public var tailport: GVEdgePortPos
    @GVGraphvizProperty<GVEdgeParameters, GVEdgePortPos> public var headport: GVEdgePortPos
    @GVGraphvizProperty<GVEdgeParameters, Bool> public var headclip: Bool
    
    init(
        edge: GVEdge
    ) {
        self.edge = edge
        _weight = GVGraphvizProperty(key: .weight, defaultValue: 1, container: edge)
        _arrowheadType = GVGraphvizProperty(key: .arrowhead, defaultValue: .normal, container: edge)
        _arrowtailType = GVGraphvizProperty(key: .arrowtail, defaultValue: .normal, container: edge)
        _dir = GVGraphvizProperty(key: .dir, defaultValue: .forward, container: edge)
        _len = GVGraphvizProperty(key: .len, defaultValue: 1.0, container: edge)
        _minlen = GVGraphvizProperty(key: .minlen, defaultValue: 1, container: edge)
        _penwidth = GVGraphvizProperty(key: .penwidth, defaultValue: 1.0, container: edge)
        _fontsize = GVGraphvizProperty(key: .fontsize, defaultValue: 14.0, container: edge)
        _fontname = GVGraphvizProperty(key: .fontname, defaultValue: "Times-Roman", container: edge)
        _style = GVGraphvizProperty(key: .style, defaultValue: .none, container: edge)
        _constraint = GVGraphvizProperty(key: .constraint, defaultValue: true, container: edge)
        _tailport = GVGraphvizProperty(key: .tailport, defaultValue: .center, container: edge)
        _headport = GVGraphvizProperty(key: .headport, defaultValue: .center, container: edge)
        _headclip = GVGraphvizProperty(key: .headclip, defaultValue: true, container: edge)
    }
    
    convenience init(
        parent: GVGraph,
        from source: Node,
        to target: Node
    ) throws {
        guard let edge = agedge(parent, source.node, target.node, nil, 1) else {
            throw Error.invalidGVEdge
        }
        self.init(edge: edge)
    }
}
