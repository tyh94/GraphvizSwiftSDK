//
//  RendererSwiftUI.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import SwiftUI
@preconcurrency import CGraphvizSDK

enum RendererError: LocalizedError {
    case createLayoutError
    
    var errorDescription: String? {
        switch self {
        case .createLayoutError:
            return "Failed to create layout"
        }
    }
}

public final class RendererSwiftUI {
    public let layout: GVLayout
    
    init(layout: GVLayout) {
        self.layout = layout
    }
    
    public func layout(graph: Graph) throws -> GraphUI {
        guard let context = loadGraphvizLibraries() else {
            throw RendererError.createLayoutError
        }
        defer {
            gvFreeLayout(context, graph.graph)
            gvFreeContext(context)
        }
        guard gvLayout(context, graph.graph, layout.rawValue) == 0 else {
            throw RendererError.createLayoutError
        }
        let graphHeight = graph.size.height
        let nodes = graph.nodes.map {
            $0.create(graphHeight: graphHeight)
        }
        let edges = graph.edges.compactMap {
            $0.create(graphHeight: graphHeight)
        }
        let subgraphsNodes = graph.subgraphs.flatMap { subgraph in
            subgraph.nodes.map {
                $0.create(graphHeight: graphHeight)
            }
        }
        let subgraphsEdges = graph.subgraphs.flatMap { subgraph in
            subgraph.edges.compactMap {
                $0.create(graphHeight: graphHeight)
            }
        }
        return GraphUI(
            size: graph.size,
            nodes: nodes + subgraphsNodes,
            edges: edges + subgraphsEdges
        )
    }
}
