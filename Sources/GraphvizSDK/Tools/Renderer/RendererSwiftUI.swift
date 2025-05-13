//
//  RendererSwiftUI.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import SwiftUI
@preconcurrency import CGraphvizSDK

enum RendererError: Error {
    case edgeError
    case createLayoutError
}

public final class RendererSwiftUI {
    public let layout: GVLayout
    private let context: GVGlobalContextPointer
    
    init(layout: GVLayout) {
        self.layout = layout
        
        // Инициализация контекста и графа
        context = loadGraphvizLibraries()
    }
    
    public func layout(graph: Graph) throws -> GraphUI {
        guard gvLayout(context, graph.graph, layout.rawValue) == 0 else {
            throw RendererError.createLayoutError
        }
        let graphHeight = graph.size.height
        let nodes = graph.nodes.map {
            $0.create(graphHeight: graphHeight)
        }
        let edges = try graph.edges.map {
            try $0.create(graphHeight: graphHeight)
        }
        let subgraphsNodes = graph.subgraphs.flatMap { subgraph in
            subgraph.nodes.map {
                $0.create(graphHeight: graphHeight)
            }
        }
        let subgraphsEdges = try graph.subgraphs.flatMap { subgraph in
            try subgraph.edges.map {
                try $0.create(graphHeight: graphHeight)
            }
        }
        return GraphUI(nodes: nodes + subgraphsNodes, edges: edges + subgraphsEdges)
    }
}
