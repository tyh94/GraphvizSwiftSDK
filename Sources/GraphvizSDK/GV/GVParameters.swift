//
//  GVParameters.swift
//  Vithanco
//
//  Created by Klaus Kneupner on 19/01/2019.
//  Copyright © 2019 Klaus Kneupner. All rights reserved.
//

import Foundation
import CoreGraphics


let pointsPerInch: CGFloat = 72.0

public func pixelToInchParameter(_ x: CGFloat) -> String {
    return "\(x / pointsPerInch)"
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
    case label
    case pad
    case labelloc
    case labeljust
    case fontsize
    case epsilon
    case rank
    case newrank
}

public enum GVNodeParameters: String, CaseIterable {
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
}

public enum GVParameter: Hashable {
    case graph(GVGraphParameters)
    case edge(GVEdgeParameters)
    case node(GVNodeParameters)
}

public enum GVEdgeParamDir: String, CaseIterable {
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

public enum GVParamValueOverlap : String {
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

//public enum GVEdgeStyle: String {
//    case curved
//    case lines
//    case polyLines
//    case orthogonal
//    case splines
//}


public enum GVRank: String {
    case same
    case min
    case source
    case max
    case sink
}

