//
//  GVLUtils.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 25.03.2025.
//

import CGraphvizSDK
import CoreGraphics
import UIKit
import OSLog

public final class GVLUtils {
    
    // MARK: - Graph Dimensions
    
    public static func getHeight(for graph: GVGraph) -> CGFloat {
        graph.height
    }
    
    // MARK: - Polygon Conversion
    
    public static func toPolygon(_ poly: polygon_t, width: CGFloat, height: CGFloat) -> [CGPoint] {
        guard poly.peripheries == 1 else {
            Logger.graphviz.warning(message: "Unsupported number of peripheries \(poly.peripheries)")
            return []
        }
        
        return (0..<poly.sides).map { side in
            let vertex = poly.vertices[side]
            return CGPoint(
                x: CGFloat(vertex.x) + width/2,
                y: CGFloat(vertex.y) + height/2
            )
        }
    }
    
    // MARK: - Path Conversion
    
    public static func toPath(type: GVNodeShape, poly: polygon_t, width: CGFloat, height: CGFloat) -> CGPath {
        var points = toPolygon(poly, width: width, height: height)
        if points.count == 2 {
            let points = toPolygon(poly, width: width, height: height)
            
            let p1 = points[0]
            let p2 = points[1]
            let rect = CGRect(origin: p1, size: CGSize(width: p2.x, height: p2.y))
            return CGPath(ellipseIn: rect, transform: nil)
        }
        
        if let first = points.first {
            points.append(first)
        }
        return toPath(points: points)
    }
    
    public static func toPath(splines: splines, height: CGFloat) -> CGPath {
        let path = CGMutablePath()
        
        guard let bezierList = splines.list, bezierList.pointee.size % 3 == 1 else {
            return path
        }
        
        let bezier = bezierList.pointee
        if (bezier.sflag != 0) {
            let start = toPointF(bezier.sp, height: height)
            path.move(to: start)
            let first = toPointF(bezier.list[0], height: height)
            path.addLine(to: first)
        } else {
            let first = toPointF(bezier.list[0], height: height)
            path.move(to: first)
        }
        
        for i in stride(from: 1, to: Int(bezier.size), by: 3) {
            let p1 = toPointF(bezier.list[i], height: height)
            let p2 = toPointF(bezier.list[i+1], height: height)
            let p3 = toPointF(bezier.list[i+2], height: height)
            path.addCurve(to: p3, control1: p1, control2: p2)
        }
        
        if (bezier.eflag != 0) {
            let end = toPointF(bezier.ep, height: height)
            path.move(to: end)
        }
        
        return path
    }
    
    public static func toPath(points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else { return path }
        
        path.move(to: first)
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        return path
    }
    
    // MARK: - Coordinate Conversion
    
    public static func toPointF(_ p: pointf, height: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(p.x), y: height - CGFloat(p.y))
    }
    
    public static func toPoint(_ p: point, height: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(p.x), y: height - CGFloat(p.y))
    }
    
    public static func centerToOrigin(_ point: CGPoint, width: CGFloat, height: CGFloat) -> CGPoint {
        return CGPoint(
            x: point.x - width/2,
            y: point.y - height/2
        )
    }
    
    // MARK: - Arrow Drawing
    
    public static func arrow(from start: CGPoint,
                             to end: CGPoint,
                             tailWidth: CGFloat,
                             headWidth: CGFloat,
                             headLength: CGFloat) -> UIBezierPath {
        
        let length = hypot(end.x - start.x, end.y - start.y)
        let tailLength = length - headLength
        
        let points = [
            CGPoint(x: 0, y: tailWidth/2),
            CGPoint(x: tailLength, y: tailWidth/2),
            CGPoint(x: tailLength, y: headWidth/2),
            CGPoint(x: length, y: 0),
            CGPoint(x: tailLength, y: -headWidth/2),
            CGPoint(x: tailLength, y: -tailWidth/2),
            CGPoint(x: 0, y: -tailWidth/2)
        ]
        
        let cosine = (end.x - start.x) / length
        let sine = (end.y - start.y) / length
        
        let transform = CGAffineTransform(
            a: cosine, b: sine,
            c: -sine, d: cosine,
            tx: start.x, ty: start.y
        )
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        
        let uiPath = UIBezierPath(cgPath: path)
        uiPath.close()
        return uiPath
    }
}

// MARK: - Graphviz Integration

extension GVGraph {
    func getBoundingBox() -> boxf {
        gd_bb(self)
    }
}
