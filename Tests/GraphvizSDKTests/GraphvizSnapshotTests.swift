//
//  GraphvizSnapshotTests.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 09.06.2025.
//

import Testing
@testable import GraphvizSDK
import SwiftUI
import SnapshotsKit

@MainActor
@Suite(.snapshots(record: .all))
struct GraphvizSnapshotTests {
    // Снепшот-тест: graphBuilder
    @available(iOS 17.0, *)
    @Test func testGraphCanvasViewSnapshot_graphBuilder() async throws {
        let graph = graphBuilder()
        let renderer = RendererSwiftUI(layout: .dot)
        let graphUI = try renderer.layout(graph: graph)
        let view = GraphCanvasView(graph: graphUI).frame(width: 300, height: 300)
        assertSnapshot(of: view, named: #function)
    }
    
    // Снепшот-тест: rankStrGraph
    @available(iOS 17.0, *)
    @Test func testGraphCanvasViewSnapshot_rankStrGraph() async throws {
        let graph = rankStrGraph()
        let renderer = RendererSwiftUI(layout: .dot)
        let graphUI = try renderer.layout(graph: graph)
        let view = GraphCanvasView(graph: graphUI)
            .frame(width: 400, height: 400)
        assertSnapshot(of: view, named: #function)
    }
    
    // Снепшот-тест: rankGraph
    @available(iOS 17.0, *)
    @Test func testGraphCanvasViewSnapshot_rankGraph() async throws {
        let graph = rankGraph()
        let renderer = RendererSwiftUI(layout: .dot)
        let graphUI = try renderer.layout(graph: graph)
        let view = GraphCanvasView(graph: graphUI).frame(width: 300, height: 200)
        assertSnapshot(of: view, named: #function)
    }
    
    // Снепшот-тест: demoGraph
    @available(iOS 17.0, *)
    @Test func testGraphCanvasViewSnapshot_demoGraph() async throws {
        let graph = demoGraph()
        let renderer = RendererSwiftUI(layout: .dot)
        let graphUI = try renderer.layout(graph: graph)
        let view = GraphCanvasView(graph: graphUI).frame(width: 700, height: 1200)
        assertSnapshot(of: view, named: #function)
    }
}
