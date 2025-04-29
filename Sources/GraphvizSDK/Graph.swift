//
//  Graph.swift
//  GraphLayout
//
//  Copyright © 2018 bakhtiyor.com.
//  MIT License
//

@preconcurrency import CGraphvizSDK
import Foundation
import CoreGraphics
import OSLog

open class Graph {
    private var graph: GVGraph
    private let context: GVGlobalContextPointer
    
    public var nodesDraw: [Node] {
        nodes + subgraphs.flatMap { $0.nodes }
    }
    
    public var edgesDraw: [Edge] {
        edges + subgraphs.flatMap { $0.edges }
    }

    private var nodes = [Node]()
    private var edges = [Edge]()
    private var subgraphs = [Subgraph]()
    public var size: CGSize {
        let bb = graph.getBoundingBox()
        return CGSize(width: CGFloat(bb.UR.x), height: CGFloat(bb.UR.y))
    }
    
    public func setBaseParameters(params: [GVGraphParameters: String]) {
        params.forEach { setAttribute($0.value, forKey: $0.key) }
    }
    
    public convenience init(type: GVGraphType = .nonStrictDirected) {
        let name = "graph_\(arc4random())"
        let cName = cString(name)
        let graph = agopen(cName, type.graphvizValue, nil)!
        self.init(graph)
    }
    
    public convenience init(str: String) {
        let graph = agmemread(str)!
        self.init(graph)
        fillNodesAndEdges()
    }
    
    public init(_ graph: GVGraph) {
        self.graph = graph
        
        // Инициализация контекста и графа
        context = loadGraphvizLibraries()
    }
    
    func fillNodesAndEdges() {
        var currentNode: GVNode? = agfstnode(graph)
        while currentNode != nil {
            let node = Node(node: currentNode!)
            nodes.append(node)
            
            var currentEdge: GVEdge? = agfstout(graph, currentNode!)
            while currentEdge != nil {
                let edge = Edge(edge: currentEdge!)
                edges.append(edge)
                currentEdge = agnxtout(graph, currentEdge!)
            }
            
            currentNode = agnxtnode(graph, currentNode!)
        }
    }
    
    // MARK: - Attributes Management
    public func setAttribute(_ value: String, forKey key: GVGraphParameters) {
        agsafeset(graph, cString(key.rawValue), cString(value), "")
    }
    
    public func getAttribute(forKey key: GVGraphParameters) -> String {
        guard let cValue = agget(graph, cString(key.rawValue)) else {
            return ""
        }
        return String(cString: cValue)
    }
    
    // MARK: - Nodes & Edges Management
    
    public func addNode(label: String) -> Node {
        let node = Node(parent: graph, label: label)
        nodes.append(node)
        return node
    }
    
    public func addEdge(from source: Node, to target: Node) -> Edge {
        let edge = Edge(parent: graph, from: source, to: target)
        edges.append(edge)
        return edge
    }
    
    public func addSubgraph(name: String) -> Subgraph {
        let subgraph = Subgraph(name: name, parent: graph)
        subgraphs.append(subgraph)
        return subgraph
    }
    
    public func setSameRank(nodes: [String]) {
        let nodesStr = nodes.joined(separator: "; ")
        let sameNodes = "\(GVRank.same.rawValue); \(nodesStr)"
        setAttribute(sameNodes, forKey: .rank)
    }
    
    // MARK: - Layout Operations
    
    @discardableResult
    @MainActor
    public func applyLayout() -> Bool {
        guard gvLayout(context, graph, "dot") == 0 else { return false }
        
        var data: CHAR?
        var len: size_t = 0
        gvRenderData(context, graph, "dot", &data, &len)
        if let data {
            Logger.graphviz.debug(message: "==========================")
            Logger.graphviz.debug(message: String(cString: data))
            Logger.graphviz.debug(message: "==========================")
        }
        let graphHeight = graph.height
        nodes.forEach { $0.prepare(graphHeight: graphHeight) }
        edges.forEach { $0.prepare(graphHeight: graphHeight) }
        subgraphs.forEach { subgraph in
            subgraph.nodes.forEach { $0.prepare(graphHeight: graphHeight) }
            subgraph.edges.forEach { $0.prepare(graphHeight: graphHeight) }
        }
        
        return true
    }
}
