//
//  File.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 25.03.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation
import CoreGraphics
import OSLog

public class GVLGraph {
    private var graph: GVGraph
    private let context: GVGlobalContextPointer
    public var nodes: [GVLNode] = []
    public var edges: [GVLEdge] = []
    
    public convenience init(type: GVGraphType = .nonStrictDirected) {
        let name = "graph_\(arc4random())"
        let cName = strdup(name)
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
        context = gvContext()
        gvAddLibrary(context, &gvplugin_dot_layout_LTX_library)
        gvAddLibrary(context, &gvplugin_core_LTX_library)
        
        // Установка атрибутов графа
        setAttribute("spline", forKey: .splines)
        setAttribute(GVParamValueOverlap.scalexy.rawValue, forKey: .overlap)
        
    }
    
    func fillNodesAndEdges() {
        var currentNode: GVNode? = agfstnode(graph)
        while currentNode != nil {
            let node = GVLNode(parent: graph, node: currentNode!)
            nodes.append(node)
            
            var currentEdge: GVEdge? = agfstout(graph, currentNode!)
            while currentEdge != nil {
                let edge = GVLEdge(parent: graph, edge: currentEdge!)
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
    
    public func addNode(label: String) -> GVLNode {
        let node = GVLNode(parent: graph, label: label)
        nodes.append(node)
        return node
    }
    
    public func addEdge(from source: GVLNode, to target: GVLNode) -> GVLEdge {
        let edge = GVLEdge(parent: graph, from: source, to: target)
        edges.append(edge)
        return edge
    }
    
    public func addSubgraph() -> GVLSubgraph {
        GVLSubgraph(parent: graph)
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
        
        nodes.forEach { $0.prepare() }
        edges.forEach { $0.prepare() }
        
        return true
    }
    
    // MARK: - Graph Properties
    
    public var size: CGSize {
        let bb = graph.getBoundingBox()
        return CGSize(width: CGFloat(bb.UR.x), height: CGFloat(bb.UR.y))
    }
    
    deinit {
        gvFreeLayout(context, graph)
        agclose(graph)
        gvFreeContext(context)
    }
}
