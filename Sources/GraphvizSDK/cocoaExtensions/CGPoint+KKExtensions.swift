//
//  CGPoint+KKExtensions.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

import Foundation
import CoreGraphics
@preconcurrency import CGraphvizSDK

extension CGPoint {
    func shift(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }

    func shift(_ dir: CGVector) -> CGPoint {
        CGPoint(x: self.x + dir.dx, y: self.y + dir.dy)
    }
    
    func substract(_ dir: CGPoint) -> CGPoint {
        CGPoint(x: self.x - dir.x, y: self.y - dir.y)
    }

    var flipped: CGPoint {
        CGPoint(x: self.y, y: self.x)
    }
	
    func interpolate(to: CGPoint, distance: CGFloat) -> CGPoint {
        let x = CGFloat(1 - distance) * self.x + CGFloat(distance) * to.x
        let y = CGFloat(1 - distance) * self.y + CGFloat(distance) * to.y
        return CGPoint(x: x, y: y)
    }
    
    func interpolateAndOrthoVector(to: CGPoint, distance: CGFloat) -> (CGPoint, CGVector) {
        let x = CGFloat(1 - distance) * self.x + CGFloat(distance) * to.x
        let y = CGFloat(1 - distance) * self.y + CGFloat(distance) * to.y
        return (CGPoint(x: x, y: y), CGVector(from: self,to: to).orthogonalVector) //.normalized())
    }
    
	func distance(to: CGPoint)-> CGFloat {
        let xDist: CGFloat = to.x - self.x
        let yDist: CGFloat = to.y - self.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    var isFinite: Bool {
        x.isFinite && y.isFinite
    }
    
    var makeNegative: CGPoint {
        CGPoint(x: -1.0 * self.x, y: -1.0 * self.y)
    }
    var asVector: CGVector {
        CGVector(dx: x, dy: y)
    }
    
    func orderByDistance(set: Set<CGPoint>) -> [CGPoint] {
        self.orderByDistance(points: set.asArray)
    }
    
    func orderByDistance(points: [CGPoint]) -> [CGPoint] {
        points.sorted(by: {a, b in return self.distance(to: a) > self.distance(to: b)})
    }
    
    func orderByDistance(_ a : CGPoint, _ b: CGPoint) -> (CGPoint, CGPoint) {
        self.distance(to: a) > self.distance(to: b) ? (b, a) : (a, b)
    }

    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        CGPoint(x: left.x / right, y: left.y / right)
    }
    
    static func / (left: CGPoint, right: Int) -> CGPoint {
        left / CGFloat(right)
    }
    
    func convertZeroPointToNil(precision: CGFloat = 0.1) -> CGPoint? {
        if self.distance(to: .zero) < precision {
            return nil
        }
        return self
    }
    
    init (gvPoint: pointf_s) {
        self.init(x: CGFloat(gvPoint.x), y: CGFloat(gvPoint.y))
        assert (isFinite)
    }
    
    var rounded: CGPoint {
        CGPoint(x: self.x.rounded(), y: self.y.rounded())
    }
    
    func centerToOrigin(width: CGFloat, height: CGFloat) -> CGPoint {
        CGPoint(
            x: x - width/2,
            y: y - height/2
        )
    }
}


// needed as parameter in some conversions, so I keep the extra function
func pointTransformGraphvizToCGPoint(_ point: pointf_s) -> CGPoint {
    CGPoint(gvPoint: point)
}

extension CGPoint {
    func convertFromGraphviz(graphHeight: CGFloat) -> CGPoint {
        CGPoint(x: x, y: graphHeight - y)
    }
}

public func + (left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x + right.x, y: left.y + right.y)
}

public func - (left: CGPoint, right: CGPoint) -> CGPoint {
    CGPoint(x: left.x - right.x, y: left.y - right.y)
}

/***
 * Adds a vector to a point and returns new point
 */
public func + (left: CGPoint, right: CGVector) -> CGPoint {
    CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

func convertZeroPointToNil(_ gvPos: CGPoint, precision: CGFloat = 0.1) -> CGPoint? {
    gvPos.convertZeroPointToNil(precision:precision)
}

public func midPoint(between: CGPoint, and: CGPoint) -> CGPoint{
    (between + and) / 2
}

extension point {
    func toCGPoint(graphHeight: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(x), y: graphHeight - CGFloat(y))
    }
}

extension pointf {
    func toCGPoint(graphHeight: CGFloat) -> CGPoint {
        CGPoint(x: CGFloat(x), y: graphHeight - CGFloat(y))
    }
}
