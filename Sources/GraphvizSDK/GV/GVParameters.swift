//
//  GVParameters.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

import Foundation
import CoreGraphics

let pointsPerInch: CGFloat = 72.0

public func pixelToInchParameter(_ x: CGFloat) -> String {
    "\(x / pointsPerInch)"
}

public enum GVEdgeParameters : String {
    case arrowtail
    case arrowhead
    case dir
    case weight
    case height
    case constraint
    case label
    case xlabel
    case samehead
    case headport
    case sametail
    case tailport
    case style
    case headlabel
    case headtooltip 
    case taillabel
    case labelangle
    case labeldistance
    case labelfloat
    case labelfontsize
    case len
    case fontname
    case fontsize
    case minlen
    case penwidth
}

public enum GVLayout: String {
    case dot
    case neato
    case fdp
    case sfdp
    case circo
    case twopi
    case nop
    case nop2
    case osage
    case patchwork
}

public enum GVGraphParameters: String {
    case overlap
    case sep
    case margin  // warning: for graph in Inches, for cluster in points
    case ranksep
    case nodesep
    case rankdir
    case splines
    case fontname
    case fontsize
    case label
    case pad
    case labelloc
    case labeljust
    case epsilon
    case rank
    case newrank
    case ordering
    case concentrate
}

public enum GVLabelLocation: String {
    case t
    case b
    case c
}

public enum GVNodeParameters: String {
    case width
    case height
    case shape
    case style
    case label
    case fixedsize
    case fontsize
    case fontname
    case labelloc
    case margin
    case penwidth
    case color
    case fontcolor
    case image
    case imagepos
    case imagescale
    case ordering
    case newrank
}

public enum GVParameter: Hashable {
    case graph(GVGraphParameters)
    case edge(GVEdgeParameters)
    case node(GVNodeParameters)
}

public enum GVEdgeParamDir: String {
    case both
    case forward
    case back
    case none
    
    static func showing(head: Bool, tail: Bool) -> GVEdgeParamDir {
        if head {
            if tail {
                return .both
            } else {
                return .forward
            }
        } else {
            if tail {
                return .back
            } else {
                return .none
            }
        }
    }
    
    public var opposite: GVEdgeParamDir {
        switch self {
        case .both, .none:
            return self
        case .back:
            return .forward
        case .forward:
            return .back
        }
    }
}

public enum GVParamValueOverlap: String {
    case retain = "true"
    case scale
    case prism1000
    case prism0
    case voronoi
    case scalexy
    case compress
    case vpsc
    case ipsep // requires neato and mode=ipsep
    case fdpDefault = "9:prism"
    case `false` = "false"
}

public enum GVEdgeEnding: String {
    /// no ending
    case none
    
    ///arrow
    case normal
    
    ///small circle
    case dot
    
    ///diamond
    case diamond
}

public enum GVEdgePortPos: String {
    case top = "n" // north (top)
    case topRight = "ne" // north-east (top-right)
    case right = "e" // east (right)
    case bottomRight = "se" // south-east (bottom-right)
    case bottom = "s" // south (bottom)
    case bottomLeft = "sw" // south-west (bottom-left)
    case left = "w" // west (left)
    case topLeft = "nw" // north-west (top-left)
    case center = "c" // center
    case `default` = "_" // default
}

public enum GVRank: String {
    case same
    case min
    case source
    case max
    case sink
    case none = ""
}

public enum GVImagePosition: String {
    case topLeft = "tl"
    case topCentered = "tc"
    case topRight = "tr"
    case middleLeft = "ml"
    case middleCentered = "mc" // default
    case middleRight = "mr"
    case bottomLeft = "bl"
    case bottomCentered = "bc"
    case bottomRight = "br"
}

public enum GVImageScale: String {
    case on = "true"
    case off = "false"
    case width
    case height
    case both
}

public enum GVOrdering: String {
    case out
    case `in`
    case none = ""
}
