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

@available(iOS 17.0, *)
public struct GraphCanvasView: View {
    let graph: GraphUI
    let onTapNode: ((NodeUI) -> ())?
    
    @State private var images: [String: Image] = [:]
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
                    if let swiftUIImage = images[node.id] {
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
                            .foregroundColor(node.textColor),
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
            for node in graph.nodes {
                if images[node.id] != nil { continue }
                guard
                    let imagePath = node.imagePath,
                    let image = await ImageCache.shared.load(path: imagePath) else {
                    continue
                }
                images[node.id] = Image(uiImage: image)
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

@available(iOS 17.0, *)
#Preview {
    let graph = try! demoGraph()
    let graphUI = try! graph.render(using: .dot)
    GraphCanvasView(graph: graphUI)
}
