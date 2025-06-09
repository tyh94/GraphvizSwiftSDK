//
//  GraphvizSnapshotTests.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 09.06.2025.
//

import Testing
@testable import GraphvizSDK
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(SnapshotTesting)
import SnapshotTesting
#endif

#if canImport(SnapshotTesting)
// Снепшот-тест: graphBuilder
@Test @MainActor func testGraphCanvasViewSnapshot_graphBuilder() async throws {
    #if os(iOS)
    let graph = graphBuilder()
    let renderer = RendererSwiftUI(layout: .dot)
    let graphUI = try renderer.layout(graph: graph)
    let view = GraphCanvasView(graph: graphUI)
    let vc = UIHostingController(rootView: view)
    vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
    assertSnapshot(of: vc, as: .image)
    #endif
}

// Снепшот-тест: rankStrGraph
@Test @MainActor func testGraphCanvasViewSnapshot_rankStrGraph() async throws {
    #if os(iOS)
    let graph = rankStrGraph()
    let renderer = RendererSwiftUI(layout: .dot)
    let graphUI = try renderer.layout(graph: graph)
    let view = GraphCanvasView(graph: graphUI)
    let vc = UIHostingController(rootView: view)
    vc.view.frame = CGRect(x: 0, y: 0, width: 400, height: 300)
    assertSnapshot(of: vc, as: .image)
    #endif
}

// Снепшот-тест: rankGraph
@Test @MainActor func testGraphCanvasViewSnapshot_rankGraph() async throws {
    #if os(iOS)
    let graph = rankGraph()
    let renderer = RendererSwiftUI(layout: .dot)
    let graphUI = try renderer.layout(graph: graph)
    let view = GraphCanvasView(graph: graphUI)
    let vc = UIHostingController(rootView: view)
    vc.view.frame = CGRect(x: 0, y: 0, width: 300, height: 200)
    assertSnapshot(of: vc, as: .image)
    #endif
}

// Снепшот-тест: demoGraph
@Test @MainActor func testGraphCanvasViewSnapshot_demoGraph() async throws {
    #if os(iOS)
    let graph = demoGraph()
    let renderer = RendererSwiftUI(layout: .dot)
    let graphUI = try renderer.layout(graph: graph)
    let view = GraphCanvasView(graph: graphUI)
    let vc = UIHostingController(rootView: view)
    vc.view.frame = CGRect(x: 0, y: 0, width: 700, height: 1200)
    assertSnapshot(of: vc, as: .image)
    #endif
}
#endif
