//
//  File.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 25.03.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation
import CoreGraphics

public class GVLGraph {
    private var graph: UnsafeMutablePointer<Agraph_t>!
    private var context: UnsafeMutablePointer<GVC_t>!
    public var nodes: [GVLNode] = []
    public var edges: [GVLEdge] = []
    
    public init() {
        let name = "graph_\(arc4random())"
        
        // Инициализация контекста и графа
        context = gvContext()
        gvAddLibrary(context, &gvplugin_dot_layout_LTX_library)
        gvAddLibrary(context, &gvplugin_core_LTX_library)
        
        let cName = strdup(name)
        graph = agopen(cName, Agdesc_t.directed, nil)
        
        // Установка атрибутов графа
        setAttribute("spline", forKey: "splines")
        setAttribute("scalexy", forKey: "overlap")
    }
    
    // MARK: - Attributes Management
    
    public func getAttribute(forKey key: String) -> String? {
        let cKey = key.withCString { UnsafeMutablePointer(mutating: $0) }
          
        guard let value = agget(graph, cKey) else { return nil }
        return String(cString: value)
    }
    
    public func setAttribute(_ value: String, forKey key: String) {
        let cKey = key.withCString { UnsafeMutablePointer(mutating: $0) }
        let cValue = value.withCString { UnsafeMutablePointer(mutating: $0) }
        agsafeset(graph, cKey, cValue, "")
    }
    
    // MARK: - Nodes & Edges Management
    
    public func addNode(label: String) -> GVLNode {
        let node = GVLNode()
        node.node = agnode(graph, nil, 1)
        node.parent = graph
        node.label = label
        nodes.append(node)
        return node
    }
    
    public func addEdge(from source: GVLNode, to target: GVLNode) -> GVLEdge {
        let edge = GVLEdge()
        edge.edge = agedge(graph, source.node, target.node, nil, 1)
        edge.parent = graph
        edges.append(edge)
        return edge
    }
    
    public func deleteNode(_ node: GVLNode) -> Bool {
        guard let index = nodes.firstIndex(where: { $0 === node }) else { return false }
        agdelnode(graph, node.node)
        nodes.remove(at: index)
        return true
    }
    
    public func deleteEdge(_ edge: GVLEdge) -> Bool {
        guard let index = edges.firstIndex(where: { $0 === edge }) else { return false }
        agdeledge(graph, edge.edge)
        edges.remove(at: index)
        return true
    }
    
    // MARK: - Layout Operations
    
    @MainActor public func loadLayout(from text: String) -> Bool {
        guard let graph = text.withCString({ agmemread($0) }) else { return false }
        guard gvLayout(context, graph, "dot") == 0 else { return false }
        
        // Обновление данных
        self.graph = graph
        nodes.removeAll()
        edges.removeAll()
        
        // Парсинг узлов и ребер
        var node = agfstnode(graph)
        while node != nil {
            let gvlNode = GVLNode()
            gvlNode.node = node
            gvlNode.parent = graph
            gvlNode.label = gvlNode.getAttribute(forKey: "label")
            nodes.append(gvlNode)
            gvlNode.prepare()
            
            // Обработка ребер
            var edge = agfstout(graph, node)
            while edge != nil {
                let gvlEdge = GVLEdge()
                gvlEdge.edge = edge
                gvlEdge.parent = graph
                edges.append(gvlEdge)
                gvlEdge.prepare()
                edge = agnxtout(graph, edge)
            }
            
            node = agnxtnode(graph, node)
        }
        
        return true
    }
    
    @discardableResult
    @MainActor
    public func applyLayout() -> Bool {
        guard gvLayout(context, graph, "dot") == 0 else { return false }
        
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

extension Agdesc_t {
    static var directed: Agdesc_t {
        return get_agdirected()
    }
}
