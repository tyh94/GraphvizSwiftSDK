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
    public convenience init(
        name: String,
        parent: GVGraph
    ) {
        self.init(agsubg(parent, cString(name), 1))
    }
    
    public func setRank(_ rank: GVRankType) {
        setAttribute(rank.rawValue, forKey: .rank)
    }
}
