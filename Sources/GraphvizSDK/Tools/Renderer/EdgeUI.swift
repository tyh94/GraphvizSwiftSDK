//
//  EdgeUI.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import SwiftUI
@preconcurrency import CGraphvizSDK
import OSLog

public struct EdgeUI: Sendable, Identifiable, Equatable {
    public let id: UUID
    public let body: Path
    public let headArrow: Path?
    public let tailArrow: Path?
    public let width: CGFloat
    public let color: Color
}

extension Edge {
    func create(graphHeight: CGFloat) throws -> EdgeUI {
        guard let pathPoints = edge.getPath(),
              !pathPoints.isEmpty else {
            throw RendererError.edgeError
        }
        
        let cgPath = pathPoints.map { $0.convertFromGraphviz(graphHeight: graphHeight) }
        let buildPath = CGMutablePath()
        buildPath.move(to: cgPath[0])
        
        for i in stride(from: 1, to: cgPath.count, by: 3) {
            guard i+2 < cgPath.count else { break }
            buildPath.addCurve(to: cgPath[i + 2], control1: cgPath[i], control2: cgPath[i + 1])
        }
        
        let body = buildPath
        
        // Create arrows
        let headArrow: CGPath?
        if let arrowHead = edge.arrowHead?.convertFromGraphviz(graphHeight: graphHeight) {
            let arrowHead2 = cgPath[cgPath.count - 1]
            let headPath = definePath(pos: arrowHead, type: arrowheadType, otherPoint: arrowHead2)
            headArrow = headPath
        } else {
            headArrow = nil
        }
        
        let tailArrow: CGPath?
        if let arrowTail = edge.arrowTail?.convertFromGraphviz(graphHeight: graphHeight) {
            let arrowTail2 = cgPath[0]
            let tailPath = definePath(pos: arrowTail, type: arrowtailType, otherPoint: arrowTail2)
            tailArrow = tailPath
        } else {
            tailArrow = nil
        }
        
        return EdgeUI(
            id: UUID(),
            body: Path(body),
            headArrow: headArrow.map { Path($0) },
            tailArrow: tailArrow.map { Path($0) },
            width: CGFloat(penwidth),
            color: Color(color)
        )
    }
}

private func definePath(pos: CGPoint, type: GVEdgeEnding, otherPoint: CGPoint) -> CGPath {
    switch type {
    case .normal :
        return CGPath.arrow(startPoint: otherPoint, endPoint: pos, tailWidth: 2, headWidth: 8, headLength: otherPoint.distance(to: pos))
    case .dot:
        return CGPath.circleBetween(a: pos, and: otherPoint)
    case .none:
        let path = CGMutablePath()
        path.move(to: pos)
        path.addLine(to: otherPoint)
        return path
    case  .diamond:
        return CGPath.diamondBetween(a: pos, and: otherPoint)
    }
}



extension CGPath {
    fileprivate class func arrow(startPoint: CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> CGPath {
        let length = hypot(endPoint.x - startPoint.x, endPoint.y - startPoint.y)
        if length.isZero {
            Logger.graphviz.warning("length between start and end isZero. Why?")
        }
        
        let points = CGPath.getAxisAlignedArrowPoints(forLength: length, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        
        let transform: CGAffineTransform = CGPath.transformForStartPoint(startPoint: startPoint, endPoint: endPoint, length: length)
        
        let path = CGMutablePath()
        path.addLines(between: points, transform: transform)
        
        return path
    }
    
    private class func getAxisAlignedArrowPoints(forLength: CGFloat, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat ) -> [CGPoint] {
        
        let tailLength = forLength - headLength
        return [
            CGPoint(x: 0, y: tailWidth/2),
            CGPoint(x: tailLength, y: tailWidth/2),
            CGPoint(x: tailLength, y: headWidth/2),
            CGPoint(x: forLength, y: 0),
            CGPoint(x: tailLength, y: -headWidth/2),
            CGPoint(x: tailLength, y: -tailWidth/2),
            CGPoint(x: 0, y: -tailWidth/2),
        ]
    }
    
    private class func transformForStartPoint(startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine: CGFloat = (endPoint.x - startPoint.x)/length
        let sine: CGFloat = (endPoint.y - startPoint.y)/length
        
        return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint.x, ty: startPoint.y)
    }
    
    fileprivate class func circle(point: CGPoint, radius: CGFloat) -> CGPath {
        let rect = CGRect(midPoint: point, size: CGSize(width: radius * 2, height: radius * 2))
        return CGPath(ellipseIn: rect, transform: nil)
    }
    
    fileprivate class func circleBetween(a: CGPoint, and b: CGPoint) -> CGPath {
        let distance = a.distance(to: b)
        let middle = midPoint(between: a, and: b)
        let rect = CGRect(midPoint: middle, size: CGSize(width: distance, height: distance))
        return CGPath(ellipseIn: rect, transform: nil)
    }
    
    fileprivate class func diamondBetween(a: CGPoint, and b: CGPoint) -> CGPath {
        let vector = CGVector(from: a, to: b)
        let distance = a.distance(to: b)
        let ortho = vector.orthogonalVector.normalized() * (distance / 3)
        
        let middle = midPoint(between: a, and: b)
        
        let c = middle + ortho
        let d = middle + ortho.opposingVector
        let path = CGMutablePath()
        path.move(to: a)
        path.addLine(to: c)
        path.addLine(to: b)
        path.addLine(to: d)
        path.addLine(to: a)
        return path
    }
}
