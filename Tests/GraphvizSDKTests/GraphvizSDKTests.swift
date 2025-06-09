import Testing
@testable import GraphvizSDK
#if canImport(SwiftUI)
import SwiftUI
#endif

// Тест: создание пустого графа
@Test func testCreateEmptyGraph() async throws {
    let graph = Graph(name: "TestGraph", type: .nonStrictDirected)
    #expect(graph.nodes.isEmpty)
    #expect(graph.edges.isEmpty)
    #expect(graph.subgraphs.isEmpty)
    #expect(graph.fontname == "Times-Roman")
    #expect(graph.fontsize == 14.0)
}

// Тест: добавление узлов
@Test func testAddNodes() async throws {
    var graph = Graph(name: "TestGraph", type: .nonStrictDirected)
    let node1 = Node(parent: graph.graph, name: "A")
    let node2 = Node(parent: graph.graph, name: "B")
    graph.append(node1)
    graph.append(node2)
    #expect(graph.nodes.count == 2)
}

// Тест: добавление рёбер
@Test func testAddEdges() async throws {
    var graph = Graph(name: "TestGraph", type: .nonStrictDirected)
    let node1 = Node(parent: graph.graph, name: "A")
    let node2 = Node(parent: graph.graph, name: "B")
    graph.append(node1)
    graph.append(node2)
    let edge = Edge(parent: graph.graph, from: node1, to: node2)
    graph.append(edge)
    #expect(graph.edges.count == 1)
}

// Тест: добавление подграфа
@Test func testAddSubgraph() async throws {
    var graph = Graph(name: "TestGraph", type: .nonStrictDirected)
    let subgraph = Subgraph(name: "sub1", parent: graph.graph)
    graph.append(subgraph)
    #expect(graph.subgraphs.count == 1)
}

// Тест: свойства графа
@Test func testGraphProperties() async throws {
    let graph = Graph(name: "TestGraph", type: .nonStrictDirected)
    #expect(graph.splines == .none)
    #expect(graph.rankdir == .towardsTop)
    #expect(graph.overlap == .retain)
}

// Тест: свойства узла
@Test func testNodeProperties() async throws {
    let graph = Graph(name: "TestGraph", type: .nonStrictDirected)
    let node = Node(parent: graph.graph, name: "A")
    #expect(node.label == "")
    #expect(node.fontSize == 14)
    #expect(node.width == 1.0)
    #expect(node.height == 1.0)
    #expect(node.shape == .ellipse)
}

// Тест: свойства ребра
@Test func testEdgeProperties() async throws {
    let graph = Graph(name: "TestGraph", type: .nonStrictDirected)
    let node1 = Node(parent: graph.graph, name: "A")
    let node2 = Node(parent: graph.graph, name: "B")
    let edge = Edge(parent: graph.graph, from: node1, to: node2)
    #expect(edge.weight == 1)
    #expect(edge.arrowheadType == .normal)
    #expect(edge.arrowtailType == .normal)
    #expect(edge.dir == .forward)
    #expect(edge.penwidth == 1.0)
    #expect(edge.fontsize == 14.0)
}
