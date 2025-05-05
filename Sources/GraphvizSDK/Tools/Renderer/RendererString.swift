//
//  RendererString.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 05.05.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

public final class RendererString {
    enum Error: Swift.Error {
        case failedCreateContext
        case failedRenderData
    }
    
    public let layout: GVLayout
    private let context: GVGlobalContextPointer
    
    init(layout: GVLayout) {
        self.layout = layout
        
        // Инициализация контекста и графа
        context = loadGraphvizLibraries()
    }
    
    public func layout(graph: Graph) throws -> String {
        guard gvLayout(context, graph.graph, layout.rawValue) == 0 else {
            throw Error.failedCreateContext
        }
        var data: CHAR?
        var len: size_t = 0
        gvRenderData(context, graph.graph, layout.rawValue, &data, &len)
        guard let data else {
            throw Error.failedRenderData
        }
        return String(cString: data)
    }
}
