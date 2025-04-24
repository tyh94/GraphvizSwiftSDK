//
//  NodeShape.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

import Foundation

// https://graphviz.org/doc/info/shapes.html
public enum GVNodeShape: String {
    case rectangle
    case box
    case hexagon
    case polygon
    case diamond
    case star
    case ellipse
    case circle
    case oval
    case triangle
    case mDiamond = "Mdiamond"
    case mSquare = "Msquare"
    case egg
    case parallelogram
//    case doublecircle // TODO: add peripheries
    
    case none
}
