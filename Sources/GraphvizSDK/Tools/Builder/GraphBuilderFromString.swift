//
//  GraphBuilderFromString.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.05.2025.
//

import Foundation
@preconcurrency import CGraphvizSDK

public final class GraphBuilderFromString {
    public enum GraphBuilderError: Error {
        case invalidGraphString
        case graphInitializationFailed
        case nodeProcessingFailed
        case edgeProcessingFailed
    }
    
    public static func build(str: String) throws -> Graph {
        guard let gvGraph = agmemread(str) else {
            throw GraphBuilderError.invalidGraphString
        }
        
        let graph = Graph(gvGraph)
        
        var currentNode: GVNode? = agfstnode(gvGraph)
        while let node = currentNode {
            do {
                let nodeName = "node_\(arc4random())"
                let graphNode = try Node(node: node, name: nodeName)
                graph.append(graphNode)
                
                var currentEdge: GVEdge? = agfstout(gvGraph, node)
                while let edge = currentEdge {
                    let graphEdge = try Edge(edge: edge)
                    graph.append(graphEdge)
                    currentEdge = agnxtout(gvGraph, edge)
                }
                
            } catch {
                throw GraphBuilderError.nodeProcessingFailed
            }
            
            currentNode = agnxtnode(gvGraph, node)
        }
        
        return graph
    }
}
