//
//  GraphUI.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import SwiftUI
@preconcurrency import CGraphvizSDK

public struct GraphUI {
    public let size: CGSize
    public var nodes: [NodeUI]
    public var edges: [EdgeUI]
    
    public init(
        size: CGSize,
        nodes: [NodeUI],
        edges: [EdgeUI]
    ) {
        self.size = size
        self.nodes = nodes
        self.edges = edges
    }
}
