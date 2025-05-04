//
//  Graph+Rendering.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation

extension Graph {
    public func render(using layout: GVLayout) throws -> GraphUI {
        try Renderer(layout: layout).layout(graph: self)
    }
}
