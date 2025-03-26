//
//  GraphCanvasView.swift
//  GraphLayout_Example
//
//  Created by Татьяна Макеева on 23.03.2025.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import SwiftUI
import GraphvizSDK

struct GraphCanvasView: View {
    var graph: Graph = DataSource.createGraph()
    
    @State private var location = CGPoint.zero
    @GestureState private var startLocation: CGPoint? = nil
    @State private var currentZoom = 0.0
    @State private var totalZoom = 1.0
    
    var body: some View {
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
    GraphCanvasView()
}
