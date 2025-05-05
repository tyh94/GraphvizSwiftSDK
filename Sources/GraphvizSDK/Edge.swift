//
//  Edge.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import UIKit
import CoreGraphics
import OSLog

public class Edge {
    let edge: GVEdge
    public var color: UIColor = UIColor.black
    
    @GVGraphvizProperty<GVEdgeParameters, Float> public var weight: Float
    @GVGraphvizProperty<GVEdgeParameters, GVEdgeEnding> public var arrowheadType: GVEdgeEnding
    @GVGraphvizProperty<GVEdgeParameters, GVEdgeEnding> public var arrowtailType: GVEdgeEnding
    @GVGraphvizProperty<GVEdgeParameters, GVEdgeParamDir> public var dir: GVEdgeParamDir
    @GVGraphvizProperty<GVEdgeParameters, Int> public var minlen: Int
    @GVGraphvizProperty<GVEdgeParameters, Double> public var penwidth: Double
    @GVGraphvizProperty<GVEdgeParameters, Double> public var fontsize: Double
    @GVGraphvizProperty<GVEdgeParameters, String> public var fontname: String
    
    init(
        edge: GVEdge
    ) {
        self.edge = edge
        _weight = GVGraphvizProperty(key: .weight, defaultValue: 1, container: edge)
        _arrowheadType = GVGraphvizProperty(key: .arrowhead, defaultValue: .normal, container: edge)
        _arrowtailType = GVGraphvizProperty(key: .arrowtail, defaultValue: .normal, container: edge)
        _dir = GVGraphvizProperty(key: .dir, defaultValue: .forward, container: edge)
        _minlen = GVGraphvizProperty(key: .minlen, defaultValue: 1, container: edge)
        _penwidth = GVGraphvizProperty(key: .penwidth, defaultValue: 1.0, container: edge)
        _fontsize = GVGraphvizProperty(key: .fontsize, defaultValue: 14.0, container: edge)
        _fontname = GVGraphvizProperty(key: .fontname, defaultValue: "Times-Roman", container: edge)
    }
    
    convenience init(
        parent: GVGraph,
        from source: Node,
        to target: Node
    ) {
        let edge = agedge(parent, source.node, target.node, nil, 1)
        self.init(edge: edge!)
    }
}
