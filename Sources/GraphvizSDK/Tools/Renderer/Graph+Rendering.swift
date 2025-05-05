//
//  Graph+Rendering.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import OSLog

extension Graph {
    public func render(using layout: GVLayout) throws -> GraphUI {
        try RendererSwiftUI(layout: layout).layout(graph: self)
    }
    
    public func log() {
        do {
            let str = try RendererString(layout: .dot).layout(graph: self)
            Logger.graphviz.debug(message: "==========================")
            Logger.graphviz.debug(message: str)
            Logger.graphviz.debug(message: "==========================")
        } catch {
            Logger.graphviz.error(error: error)
        }
    }
}
