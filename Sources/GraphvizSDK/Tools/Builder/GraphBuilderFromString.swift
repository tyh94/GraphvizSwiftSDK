//
//  GraphBuilderFromString.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.05.2025.
//

import Foundation
@preconcurrency import CGraphvizSDK

public final class GraphBuilderFromString {
    public static func build(str: String) -> Graph {
        let gvGraph = agmemread(str)!
        var graph = Graph(gvGraph)
        var currentNode: GVNode? = agfstnode(gvGraph)
        while currentNode != nil {
            let node = Node(node: currentNode!)
            graph.append(node)
            
            var currentEdge: GVEdge? = agfstout(gvGraph, currentNode!)
            while currentEdge != nil {
                let edge = Edge(edge: currentEdge!)
                graph.append(edge)
                currentEdge = agnxtout(gvGraph, currentEdge!)
            }
            
            currentNode = agnxtnode(gvGraph, currentNode!)
        }
        return graph
    }
}
