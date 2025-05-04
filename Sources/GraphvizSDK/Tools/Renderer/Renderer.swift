//
//  Renderer.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import SwiftUI
@preconcurrency import CGraphvizSDK
import OSLog

enum RendererError: Error {
    case edgeError
    case createLayoutError
    
}
public final class Renderer {
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
        let edges = graph.edges.compactMap {
            try? $0.create(graphHeight: graphHeight)
        }
        return GraphUI(nodes: nodes, edges: edges)
    }
}







