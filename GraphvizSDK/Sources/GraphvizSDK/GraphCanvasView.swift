//
//  GraphCanvasView.swift
//  GraphLayout_Example
//
//  Created by Татьяна Макеева on 23.03.2025.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

public struct GraphCanvasView: View {
    public let graph: Graph
    
    @State private var location = CGPoint.zero
    @GestureState private var startLocation: CGPoint? = nil
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    public init(graph: Graph) {
        self.graph = graph
    }
    
    public var body: some View {
        Canvas { context, size in
            let globalOffset = CGAffineTransform(translationX: location.x, y: location.y)
            // TODO: плохо работает
                .scaledBy(x: currentZoom + totalZoom, y: currentZoom + totalZoom)
            for node in graph.nodes {
                let frame = node.frame()!.applying(globalOffset)
                
                context.translateBy(
                    x: frame.origin.x,
                    y: frame.origin.y
                )
                let path = Path(node.path()!.cgPath)
                context.stroke(path, with: .color(Color(node.borderColor)), lineWidth: CGFloat(node.borderWidth))
                context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
                context.draw(Text(node.label).font(Font.system(size: CGFloat(node.fontSize))), in: frame)
            }
            
            for edge in graph.edges {
                let frame = edge.frame()!.applying(globalOffset)
                let edgeWidth = CGFloat(edge.width)
                context.translateBy(
                    x: frame.origin.x,
                    y: frame.origin.y
                )
                if let path = edge.body()?.cgPath {
                    context.stroke(Path(path), with: .color(Color(edge.color)), lineWidth: CGFloat(edgeWidth))
                }
                if let path = edge.headArrow()?.cgPath {
                    context.stroke(Path(path), with: .color(Color(edge.color)), lineWidth: CGFloat(edgeWidth))
                }
                if let path = edge.tailArrow()?.cgPath {
                    context.stroke(Path(path), with: .color(Color(edge.color)), lineWidth: CGFloat(edgeWidth))
                }
                context.translateBy(
                    x: -frame.origin.x,
                    y: -frame.origin.y
                )
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    var newLocation = startLocation ?? location // 3
                    newLocation.x += value.translation.width
                    newLocation.y += value.translation.height
                    self.location = newLocation
                    if value.startLocation == value.location {
                        
                    }
                }
                .updating($startLocation) { (value, startLocation, transaction) in
                    startLocation = startLocation ?? location // 2
                }
        )
        //        .gesture(
        //            MagnifyGesture()
        //                .onChanged { value in
        //                    currentZoom = value.magnification - 1
        //                }
        //                .onEnded { value in
        //                    totalZoom += currentZoom
        //                    currentZoom = 0
        //                }
        //        )
        .onAppear {
            graph.applyLayout()
            // Центрируем график при старте
            if let firstNode = graph.nodes.first?.frame() {
                location = CGPoint(
                    x: -firstNode.midX,
                    y: -firstNode.midY
                )
            }
        }
    }
}

extension CGRect {
    /** Creates a rectangle with the given center and dimensions
     - parameter center: The center of the new rectangle
     - parameter size: The dimensions of the new rectangle
     */
    init(center: CGPoint, size: CGSize) {
        self.init(x: center.x - size.width / 2, y: center.y - size.height / 2, width: size.width, height: size.height)
    }
}

#Preview {
    GraphCanvasView(graph: demoGraph())
}

func demoGraph() -> Graph {
    let graph = Graph()
    
    let node1 = graph.addNode("The quick\nbrown fox jumps\nover the lazy\ndog")
    let node2 = graph.addNode("node 2")
    let node3 = graph.addNode("node 3")
    let node4 = graph.addNode("node\n4")
    let node5 = graph.addNode("A picture\nis worth\na thousand\nwords")
    let node6 = graph.addNode("node 6")
    let node7 = graph.addNode("node \n 7")
    let node8 = graph.addNode("node 8")
    let node9 = graph.addNode("node 9")
    let node10 = graph.addNode("node \n 10")
    let node11 = graph.addNode("node 11")
    let node12 = graph.addNode("node \n 12")
    let node13 = graph.addNode("node 13")
    let node14 = graph.addNode("node \n 14")
    let node15 = graph.addNode("node 15")
    _ = graph.addEdge(from: node1, to: node2)
    _ = graph.addEdge(from: node1, to: node5)
    _ = graph.addEdge(from: node3, to: node4)
    _ = graph.addEdge(from: node2, to: node3)
    _ = graph.addEdge(from: node4, to: node5)
    _ = graph.addEdge(from: node3, to: node5)
    _ = graph.addEdge(from: node6, to: node7)
    _ = graph.addEdge(from: node7, to: node8)
    _ = graph.addEdge(from: node8, to: node9)
    _ = graph.addEdge(from: node9, to: node10)
    _ = graph.addEdge(from: node1, to: node10)
    _ = graph.addEdge(from: node5, to: node10)
    _ = graph.addEdge(from: node5, to: node6)
    _ = graph.addEdge(from: node6, to: node5)
    let e1_8 = graph.addEdge(from: node1, to: node8)
    
    _ = graph.addEdge(from: node8, to: node1)
    let e3_10 = graph.addEdge(from: node3, to: node10)
    _ = graph.addEdge(from: node4, to: node9)
    _ = graph.addEdge(from: node3, to: node7)
    _ = graph.addEdge(from: node2, to: node8)
    _ = graph.addEdge(from: node4, to: node8)
    _ = graph.addEdge(from: node5, to: node7)
    _ = graph.addEdge(from: node5, to: node5)
    
    _ = graph.addEdge(from: node11, to: node12)
    _ = graph.addEdge(from: node12, to: node15)
    _ = graph.addEdge(from: node11, to: node13)
    _ = graph.addEdge(from: node15, to: node14)
    _ = graph.addEdge(from: node15, to: node11)
    _ = graph.addEdge(from: node11, to: node1)
    _ = graph.addEdge(from: node12, to: node1)
    _ = graph.addEdge(from: node10, to: node15)
    _ = graph.addEdge(from: node13, to: node6)
    let e9_1 = graph.addEdge(from: node9, to: node1)
    _ = graph.addEdge(from: node9, to: node11)
    _ = graph.addEdge(from: node13, to: node3)
    node2.shape = .box
    node4.shape = .hexagon
    node1.color = UIColor.yellow
    node3.fontSize = 24
    node3.textColor = UIColor.blue
    
    e9_1.color = UIColor.red
    e3_10.color = UIColor.green
    e1_8.weight = 10
    e1_8.width = 2
    e3_10.weight = 50
    e3_10.width = 3
    e9_1.weight = 100
    e9_1.width = 4
    
    return graph
}
