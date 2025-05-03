//
//  Subgraph.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 27.03.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation
import CoreGraphics
import OSLog

public class Subgraph: Graph {
    convenience init(
        name: String,
        parent: GVGraph
    ) {
        let subgraph = agsubg(parent, cString(name), 1)!
        self.init(subgraph, nodes: [], edges: [])
    }
}
