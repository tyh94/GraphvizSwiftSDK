//
//  GraphBuilderFromString.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.05.2025.
//

import Foundation
@preconcurrency import CGraphvizSDK

public final class GraphBuilderFromString {
    
    
    public func build(str: String) -> Graph {
        let gvGraph = agmemread(str)!
        
        var nodes: [Node] = []
        var edges: [Edge] = []
        
        var currentNode: GVNode? = agfstnode(gvGraph)
        while currentNode != nil {
            let node = Node(node: currentNode!)
            nodes.append(node)
            
            var currentEdge: GVEdge? = agfstout(gvGraph, currentNode!)
            while currentEdge != nil {
                let edge = Edge(edge: currentEdge!)
                edges.append(edge)
                currentEdge = agnxtout(gvGraph, currentEdge!)
            }
            
            currentNode = agnxtnode(gvGraph, currentNode!)
        }
        return Graph(gvGraph, nodes: nodes, edges: edges)
    }
}
