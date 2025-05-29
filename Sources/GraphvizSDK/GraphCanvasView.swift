//
//  GraphCanvasView.swift
//  GraphLayout_Example
//
//  Created by Татьяна Макеева on 23.03.2025.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI

actor ImageCache {
    static let shared = ImageCache()
    private var cache: [String: UIImage] = [:]
    
    func load(path: String) -> UIImage? {
        if let cached = cache[path] {
            return cached
        }
        if let image = UIImage(contentsOfFile: path) {
            cache[path] = image
            return image
        }
        return nil
    }
}

public struct GraphCanvasView: View {
    @State var graph: GraphUI
    let onTapNode: ((NodeUI) -> ())?
    
    @State private var location = CGPoint.zero
    @GestureState private var startLocation: CGPoint? = nil
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    @State private var isZooming: Bool = false
    @State private var zoomInitialLocation: CGPoint = .zero
    @State private var zoomInitialScale: CGFloat = 1.0
    @State private var zoomAnchor: CGPoint? = nil
    
    public init(
        graph: GraphUI,
        tapNode: ((NodeUI) -> ())? = nil
    ) {
        self.graph = graph
        self.onTapNode = tapNode
    }
    
    public var body: some View {
        ZStack {
            Canvas { context, size in
                context.translateBy(x: location.x, y: location.y)
                context.scaleBy(x: currentZoom + totalZoom, y: currentZoom + totalZoom)
                
                for node in graph.nodes {
                    let frame = node.frame
                    context.translateBy(
                        x: frame.origin.x,
                        y: frame.origin.y
                    )
                    if let uiImage = node.image {
                        let swiftUIImage = Image(uiImage: uiImage)
                        
                        // Размер — минимальная сторона из frame
                        let side = min(frame.width, frame.height)
                        let imageSize = CGSize(width: side, height: side)
                        
                        // Центрируем в node.frame
                        let dx = (frame.width - side) / 2
                        let dy = (frame.height - side) / 2
                        
                        let imageRect = CGRect(origin: CGPoint(x: dx, y: dy), size: imageSize)
                        
                        context.draw(swiftUIImage, in: imageRect)
                    }
                    context.stroke(node.path, with: .color(node.borderColor), lineWidth: node.borderWidth)
                    context.translateBy(x: -frame.origin.x, y: -frame.origin.y)
                    context.draw(
                        Text(node.label)
                            .font(node.textFont)
                            .foregroundStyle(node.textColor),
                        at: frame.center
                    )
                }
                
                for edge in graph.edges {
                    let edgeWidth = edge.width
                    
                    let path = edge.body
                    context.stroke(path, with: .color(edge.color), lineWidth: edgeWidth)
                    
                    if let path = edge.headArrow {
                        context.stroke(path, with: .color(edge.color), lineWidth: CGFloat(edgeWidth))
                    }
                    if let path = edge.tailArrow {
                        context.stroke(path, with: .color(edge.color), lineWidth: CGFloat(edgeWidth))
                    }
                }
            }
        }
        .gesture(
            SimultaneousGesture(
                DragGesture()
                    .updating($startLocation) { value, state, _ in
                        state = state ?? location
                    }
                    .onChanged { value in
                        // Пан, когда нет зума
                        if !isZooming {
                            let start = startLocation ?? location
                            location = CGPoint(
                                x: start.x + value.translation.width,
                                y: start.y + value.translation.height
                            )
                        } else if let anchor = zoomAnchor {
                            // Если идёт зум и пальцы двигаются
                            zoomAnchor = anchor.applying(CGAffineTransform(translationX: value.translation.width, y: value.translation.height))
                        }
                    },
                MagnifyGesture()
                    .onChanged { value in
                        if !isZooming {
                            isZooming = true
                            zoomInitialLocation = location
                            zoomInitialScale = totalZoom
                            zoomAnchor = zoomAnchor ?? .zero
                        }
                        
                        guard let anchor = zoomAnchor else { return }
                        
                        let newScale = value.magnification
                        let currentScale = zoomInitialScale * newScale
                        
                        let anchorInContent = CGPoint(
                            x: (anchor.x - zoomInitialLocation.x) / zoomInitialScale,
                            y: (anchor.y - zoomInitialLocation.y) / zoomInitialScale
                        )
                        
                        location.x = anchor.x - anchorInContent.x * currentScale
                        location.y = anchor.y - anchorInContent.y * currentScale
                        
                        currentZoom = currentScale - totalZoom
                    }
                    .onEnded { _ in
                        totalZoom += currentZoom
                        currentZoom = 0
                        isZooming = false
                        zoomAnchor = nil
                    }
            )
        )
        .task {
            // Подгрузка картинок
            for index in graph.nodes.indices {
                var node = graph.nodes[index]
                guard let imagePath = node.imagePath else { continue }
                node.image = await ImageCache.shared.load(path: imagePath)
                graph.nodes[index] = node
            }
        }
        .onTapGesture { tapLocation in
            let globalOffset = CGAffineTransform(translationX: location.x, y: location.y)
                .scaledBy(x: currentZoom + totalZoom, y: currentZoom + totalZoom)
            for node in graph.nodes {
                let frame = node.frame.applying(globalOffset)
                if frame.contains(tapLocation) {
                    self.onTapNode?(node)
                }
            }
        }
    }
}

struct CenterOnNodeModifier: ViewModifier {
    let node: NodeUI?
    @Binding var location: CGPoint
    let zoom: CGFloat
    
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            content
                .onAppear {
                    guard let node = node else { return }
                    let canvasCenter = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    // Центрируем выбранную ноду по центру экрана
                    location = CGPoint(
                        x: canvasCenter.x - node.frame.midX * zoom,
                        y: canvasCenter.y - node.frame.midY * zoom
                    )
                }
        }
    }
}

extension View {
    func centerOnNode(_ node: NodeUI?, location: Binding<CGPoint>, zoom: CGFloat = 1.0) -> some View {
        modifier(CenterOnNodeModifier(node: node, location: location, zoom: zoom))
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
    
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
}

#Preview {
    let graph = rankStrGraph()
    let graphUI = try! graph.render(using: .dot)
    GraphCanvasView(graph: graphUI)
}

func graphBuilder() -> Graph {
    let builder = GraphBuilder()
    let node1 = builder.node { node in
        node.with(shape: .box)
            .with(label: "test")
    }
    let node2 = builder.node { nodeBuilder in
        nodeBuilder.with(shape: .egg)
            .with(label: "test2")
    }
    builder.edge(source: node1, targer: node2) { edgeBuilder in
        edgeBuilder
    }
    
    let subgraphBuilder = builder.subgraph { subgraphBuilder in
        subgraphBuilder
            .with(name: "sub")
            .with(rank: .same)
    }
    let nodeAbraharm = subgraphBuilder.node { nodeBuilder in
        nodeBuilder.with(label: "Abraham")
    }
    let nodeMona = subgraphBuilder.node { nodeBuilder in
        nodeBuilder.with(label: "Mona")
    }
    let nodeDiamond = subgraphBuilder.node { nodeBuilder in
        nodeBuilder.with(label: "")
            .with(shape: .diamond)
    }
    subgraphBuilder
        .edge(
            source: nodeAbraharm,
            targer: nodeDiamond) { edgeBuilder in
                edgeBuilder
            }
    subgraphBuilder
        .edge(
            source: nodeDiamond,
            targer: nodeMona) { edgeBuilder in
                edgeBuilder
            }
    
    builder.edge(source: node2, targer: nodeDiamond) { $0 }
    return builder.build()
}

func rankStrGraph() -> Graph {
    GraphBuilderFromString.build(str:
        """
        digraph G {
                  edge [dir=none];
                  node [shape=box];
                  graph [splines=ortho];
        
                  "Herb"      [shape=parallelogram, regular=0, color="blue", style="filled" fillcolor="lightblue"] ;
                  "Homer"     [shape=parallelogram, regular=0, color="blue", style="bold, filled" fillcolor="lightblue"] ;
                  "Abraham"   [shape=parallelogram, regular=0, color="blue", style="filled" fillcolor="lightblue"] ;
                  "Mona"      [shape=egg, regular=0, color="red", style="filled" fillcolor="pink"] ;
                  
                  a1 [shape=diamond,label="",height=0.25,width=0.25];
                  b1 [shape=circle,label="",height=0.01,width=0.01];
                  b2 [shape=circle,label="",height=0.01,width=0.01];
                  b3 [shape=circle,label="",height=0.01,width=0.01];
                  a1 -> b2
                  b1 -> Herb
                  b3 -> Homer
                  {rank=same; Abraham -> a1 -> Mona};
                  {rank=same; b1 -> b2 -> b3}
                  {rank=same; Herb; Homer};
                }
        """
    )
}

func rankGraph() -> Graph {
    let graph = GraphBuilder()
    let subgraph = graph.subgraph { $0.with(name: "sub").with(rank: .same) }
    let abraham = subgraph.node {
        $0.with(label: "Abraham")
    }
    let mona = subgraph.node {
        $0.with(label: "Mona")
    }
    let diamond = subgraph.node {
        $0.with(label: "")
            .with(shape: .diamond)
    }
    subgraph.edge(source: abraham, targer: diamond, { $0 })
    subgraph.edge(source: diamond, targer: mona, { $0 })
    return graph.build()
}

func demoGraph() -> Graph {
    let graph = GraphBuilder()
    
    let node1 = graph.node {
        $0.with(label: "The quick\nbrown fox jumps\nover the lazy\ndog")
            .with(shape: .egg)
        //        node1.color = UIColor.yellow
    }
    let node2 = graph.node {
        $0.with(label: "node 2")
            .with(shape: .egg)
    }
    let node3 = graph.node {
        $0.with(label: "node 3")
        //        node3.fontSize = 24
        //        node3.textColor = UIColor.blue
    }
    let node4 = graph.node {
        $0.with(label: "node\n4")
            .with(shape: .hexagon)
    }
    let node5 = graph.node {
        $0.with(label: "A picture\nis worth\na thousand\nwords")
    }
    let node6 = graph.node {
        $0.with(label: "node 6")
    }
    let node7 = graph.node {
        $0.with(label: "node \n 7")
    }
    let node8 = graph.node {
        $0.with(label: "node 8")
    }
    let node9 = graph.node {
        $0.with(label: "node 9")
    }
    let node10 = graph.node {
        $0.with(label: "node \n 10")
    }
    let node11 = graph.node {
        $0.with(label: "node 11")
    }
    let node12 = graph.node {
        $0.with(label: "node \n 12")
    }
    let node13 = graph.node {
        $0.with(label: "node 13")
    }
    let node14 = graph.node {
        $0.with(label: "node \n 14")
    }
    let node15 = graph.node {
        $0.with(label: "node 15")
    }
    
    graph.edge(source: node1, targer: node2, { $0 })
    graph.edge(source: node1, targer: node2, { $0 })
    graph.edge(source: node1, targer: node5, { $0 })
    graph.edge(source: node3, targer: node4, { $0 })
    graph.edge(source: node2, targer: node3, { $0 })
    graph.edge(source: node4, targer: node5, { $0 })
    graph.edge(source: node3, targer: node5, { $0 })
    graph.edge(source: node6, targer: node7, { $0 })
    graph.edge(source: node7, targer: node8, { $0 })
    graph.edge(source: node8, targer: node9, { $0 })
    graph.edge(source: node9, targer: node10, { $0 })
    graph.edge(source: node1, targer: node10, { $0 })
    graph.edge(source: node5, targer: node10, { $0 })
    graph.edge(source: node5, targer: node6, { $0 })
    graph.edge(source: node6, targer: node5, { $0 })
    graph.edge(source: node1, targer: node8, {
        $0
        //        e1_8.weight = 10
        //        e1_8.width = 2
    })
    
    graph.edge(source: node8, targer: node1, { $0 })
    graph.edge(source: node3, targer: node10, {
        $0
        //        e3_10.color = UIColor.green
        //        e3_10.weight = 50
        //        e3_10.width = 3
        //        e3_10.setBaseParameters(params: [.dir: GVEdgeParamDir.both.rawValue])
        //        e3_10.arrowheadType = .dot
        //        e3_10.arrowtailType = .diamond
    })
    graph.edge(source: node4, targer: node9, { $0 })
    graph.edge(source: node3, targer: node7, { $0 })
    graph.edge(source: node2, targer: node8, { $0 })
    graph.edge(source: node4, targer: node8, { $0 })
    graph.edge(source: node5, targer: node7, { $0 })
    graph.edge(source: node5, targer: node5, { $0 })
    
    graph.edge(source: node11, targer: node12, { $0 })
    graph.edge(source: node12, targer: node15, { $0 })
    graph.edge(source: node11, targer: node13, { $0 })
    graph.edge(source: node15, targer: node14, { $0 })
    graph.edge(source: node15, targer: node11, { $0 })
    graph.edge(source: node11, targer: node1, { $0 })
    graph.edge(source: node12, targer: node1, { $0 })
    graph.edge(source: node10, targer: node15, { $0 })
    graph.edge(source: node13, targer: node6, { $0 })
    graph.edge(source: node9, targer: node1, {
        $0
        //        e9_1.color = UIColor.red
        //        e9_1.weight = 100
        //        e9_1.width = 4
        //        e9_1.setBaseParameters(params: [.dir: GVEdgeParamDir.both.rawValue])
        //        e9_1.arrowheadType = .diamond
        //        e9_1.arrowtailType = .dot
    })
    graph.edge(source: node9, targer: node11, { $0 })
    graph.edge(source: node13, targer: node3, { $0 })
    
    
    return graph.build()
}
