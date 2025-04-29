//
//  NSBezierPath+KKExtension.swift
//  VisualThinkingWithIBIS
//
//  Created by Klaus Kneupner on 23/04/2017.
//  Copyright © 2017 Klaus Kneupner. All rights reserved.
//

import OSLog
import UIKit
//
//fileprivate let logger = Logger(label: "com.vithanco.swiftgraphviz.NSBezierPath")

//  from: https://gist.github.com/mwermuth/07825df27ea28f5fc89a
extension CGPath {

    class func getAxisAlignedArrowPoints(forLength: CGFloat, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat ) -> [CGPoint] {
        
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

    class func transformForStartPoint(startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform {
        let cosine: CGFloat = (endPoint.x - startPoint.x)/length
        let sine: CGFloat = (endPoint.y - startPoint.y)/length

        return CGAffineTransform(a: cosine, b: sine, c: -sine, d: cosine, tx: startPoint.x, ty: startPoint.y)
    }

    public class func arrow(startPoint: CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> CGPath {
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

}

// from: https://swift.unicorn.tv/articles/extension-for-nsbezierpath-and-cgpath
public extension UIBezierPath {
//
//    var cgPath: CGPath {
//        get {
//            return self.transformToCGPath()
//        }
//    }
//
//    /// Transforms the NSBezierPath into a CGPathRef
//    ///
//    /// :returns: The transformed NSBezierPath
//    private func transformToCGPath() -> CGPath {
//        // Create path
//        let path = CGMutablePath()
//        let points = UnsafeMutablePointer<NSPoint>.allocate(capacity: 3)
//        let numElements = self.elementCount
//
//        if numElements > 0 {
//            for index in 0..<numElements {
//                let pathType = self.element(at: index, associatedPoints: points)
//
//                switch pathType {
//                case .moveTo :
//                    path.move(to: points[0])
//                case .lineTo :
//                    path.addLine(to: points[0])
//                case .curveTo :
//                    path.addCurve(to: points[2], control1: points[0], control2: points[1])
//                case .closePath:
//                    path.closeSubpath()
//                @unknown default:
//                    fatalError()
//                }
//            }
//        }
//
//        points.deallocate()
//        return path
//    }
//
//    //    https://gist.github.com/mcxiaoke/fadb2acf5f74d2401b788db3471fa52d 1st May 2017 combined with
//    //    http://swiftexample.info/snippet/swift/uibezierpathlengthswift_warpling_swift 2nd May 2017
//
//    convenience init(path: CGPath) {
//        self.init()
//        path.forEach(callback: { (element: CGPathElement) -> Void in
//            switch element.type {
//            case .moveToPoint:
//                self.move(to: element.points[0])
//
//            case .addLineToPoint:
//                self.line(to: element.points[0])
//
//            case .addQuadCurveToPoint:
//                let firstPoint = element.points[0]
//                let secondPoint = element.points[1]
//
//                let currentPoint = path.currentPoint
//                let x = (currentPoint.x + 2 * firstPoint.x) / 3
//                let y = (currentPoint.y + 2 * firstPoint.y) / 3
//                let interpolatedPoint = CGPoint(x: x, y: y)
//
//                let endPoint = secondPoint
//
//                self.curve(to: endPoint, controlPoint1: interpolatedPoint, controlPoint2: interpolatedPoint)
//
//            case .addCurveToPoint:
//                let firstPoint = element.points[0]
//                let secondPoint = element.points[1]
//                let thirdPoint = element.points[2]
//
//                self.curve(to: thirdPoint, controlPoint1: firstPoint, controlPoint2: secondPoint)
//
//            case .closeSubpath:
//                self.close()
//            @unknown default:
//                fatalError()
//            }
//        })
//    }

    convenience init(circleAt: CGPoint, radius: CGFloat) {
        let rect = CGRect(midPoint: circleAt, size: CGSize(width: radius * 2, height: radius * 2))
        self.init(ovalIn: rect)
    }

    convenience init(circleBetween a: CGPoint, and b: CGPoint) {
        let distance = a.distance(to: b)
        //        Swift.print("distance=\(distance)")
        let middle = midPoint(between: a, and: b)
        let rect = CGRect(midPoint: middle, size: CGSize(width: distance, height: distance))
        self.init(ovalIn: rect)
    }
//
    convenience init(diamondBetween a: CGPoint, and b: CGPoint) {
        let vector = CGVector(from: a, to: b)
        let distance = a.distance(to: b)
        let ortho = vector.orthogonalVector.normalized() * (distance / 3)

        //        Swift.print("distance=\(distance)")
        let middle = midPoint(between: a, and: b)

        let c = middle + ortho
        let d = middle + ortho.opposingVector
        self.init()
        self.move(to: a)
        self.addLine(to: c)
        self.addLine(to: b)
        self.addLine(to: d)
        self.close()
    }

    func isPointPart(_ p: CGPoint) -> Bool {
        return self.outerPath.contains(p)
    }

    var outerPath: CGPath {
        return self.cgPath.copy(strokingWithWidth: 8, lineCap: .round, lineJoin: .round, miterLimit: 1)
    }

    var outerBezierPath: UIBezierPath {
        return UIBezierPath(cgPath: outerPath)
    }

    func interpolateAndOrthoVector(distance: CGFloat) -> (CGPoint, CGVector) {
        (.zero, zeroVector)
        // TODO:
//        var count = 0
//        var elementForStep = [Int](repeating: -1, count: elementCount)
//
//        for index in 0..<self.elementCount {
//            switch element(at: index) {
//            case .moveTo:
//                continue
//            case .lineTo:
//                elementForStep[count] = index
//                count = count + 1
//            case .curveTo:
//                elementForStep[count] = index
//                count = count + 1
//            case .closePath:
//                continue
//            case .cubicCurveTo:
//                elementForStep[count] = index
//                count += 1
//            case .quadraticCurveTo:
//                elementForStep[count] = index
//                count += 1
//            @unknown default:
//                continue
//            }
//        }
//        let stepWidth = CGFloat(1.0 / CGFloat(count))
//        let step = Int((distance / stepWidth).rounded(.down))
//        let remainder = distance.remainder(dividingBy: stepWidth)
//        let elementStepNr = elementForStep[step]
//        return interpolateAndOrthoVector(element: elementStepNr, x: remainder * stepWidth)
    }

    func lastPoint(element: Int) -> CGPoint {
        .zero
        // TODO:
//        let points = NSPointArray.allocate(capacity: 3)
//        let type = self.element(at: element, associatedPoints: points)
//
//        switch type {
//        case .moveTo:
//            return points[0]
//        case .lineTo:
//            return points[0]
//        case .curveTo:
//            return points[2]
//        case .closePath:
//            assert(false)
//            return CGPoint.zero
//        case .cubicCurveTo:
//            return points[2] // The endpoint of the cubic curve
//        case .quadraticCurveTo:
//            return points[2] // Assuming quadratic curves are treated similarly, with the endpoint as the last point.
//        @unknown default:
//            assert(false)
//            return CGPoint.zero
//        }
    }

    //https://medium.com/@adrian_cooney/bezier-interpolation-13b68563313a
    func interpolateAndOrthoVector (element: Int, x: CGFloat) -> (CGPoint, CGVector) {
        (.zero, zeroVector)
        // TODO:
//        let points = NSPointArray.allocate(capacity: 3)
//        let type = self.element(at: element, associatedPoints: points)
//        let startingPoint = lastPoint(element: element - 1)
//
//        switch type {
//        case .moveTo:
//            assert(false)
//            let firstPoint = points[0]
//            return (firstPoint, zeroVector)
//
//        case .lineTo:
//            let firstPoint = points[0]
//            return startingPoint.interpolateAndOrthoVector(to: firstPoint, distance: x)
//
//        case .curveTo:
//            let firstPoint = points[0]
//            let secondPoint = points[1]
//            let thirdPoint = points[2]
//
//            let a = startingPoint.interpolate(to: firstPoint, distance: x)
//            let b = firstPoint.interpolate(to: secondPoint, distance: x)
//            let c = secondPoint.interpolate(to: thirdPoint, distance: x)
//
//            let d = a.interpolate(to: b, distance: x)
//            let e = b.interpolate(to: c, distance: x)
//
//            return d.interpolateAndOrthoVector(to: e, distance: x)
//
//        case .closePath:
//            assert(false)
//            return (CGPoint.zero, zeroVector)
//        case .cubicCurveTo:  // chatGPT, supposingly based on De Casteljau's algorithm
//            let controlPoint1 = points[0]
//            let controlPoint2 = points[1]
//            let endPoint = points[2]
//
//            // First level of interpolation
//            let a = startingPoint.interpolate(to: controlPoint1, distance: x)
//            let b = controlPoint1.interpolate(to: controlPoint2, distance: x)
//            let c = controlPoint2.interpolate(to: endPoint, distance: x)
//
//            // Second level of interpolation
//            let d = a.interpolate(to: b, distance: x)
//            let e = b.interpolate(to: c, distance: x)
//
//            // Final level of interpolation
//            let pointOnCurve = d.interpolate(to: e, distance: x)
//
//            // To find the orthogonal vector, you would typically calculate the derivative of the Bezier curve at this point.
//            // However, for simplicity, let's calculate a tangent vector from 'd' to 'e' and then find its orthogonal.
//            let tangent = CGVector(dx: e.x - d.x, dy: e.y - d.y)
//            let orthogonalVector = CGVector(dx: -tangent.dy, dy: tangent.dx) // Rotate 90 degrees to get the orthogonal vector
//
//            // Normalize the orthogonal vector if necessary
//            let length = sqrt(orthogonalVector.dx * orthogonalVector.dx + orthogonalVector.dy * orthogonalVector.dy)
//            let normalizedOrthogonalVector = CGVector(dx: orthogonalVector.dx / length, dy: orthogonalVector.dy / length)
//
//            return (pointOnCurve, normalizedOrthogonalVector)
//        case .quadraticCurveTo: // chatGPT, supposingly based on De Casteljau's algorithm
//            let controlPoint = points[0]
//            let endPoint = points[1]
//
//            // First level of interpolation: interpolate between starting point and control point, and control point and endpoint.
//            let a = startingPoint.interpolate(to: controlPoint, distance: x)
//            let b = controlPoint.interpolate(to: endPoint, distance: x)
//
//            // Second level of interpolation: interpolate between points 'a' and 'b' to find the point on the curve.
//            let pointOnCurve = a.interpolate(to: b, distance: x)
//
//            // Compute the tangent vector by subtracting point 'a' from point 'b'. This will guide us to the orthogonal vector.
//            let tangent = CGVector(dx: b.x - a.x, dy: b.y - a.y)
//            let orthogonalVector = CGVector(dx: -tangent.dy, dy: tangent.dx) // Rotate 90 degrees to get the orthogonal vector
//
//            // Normalize the orthogonal vector, assuming normalization is required for your use case.
//            let length = sqrt(orthogonalVector.dx * orthogonalVector.dx + orthogonalVector.dy * orthogonalVector.dy)
//            let normalizedOrthogonalVector = CGVector(dx: orthogonalVector.dx / length, dy: orthogonalVector.dy / length)
//
//            return (pointOnCurve, normalizedOrthogonalVector)
//
//        @unknown default:
//            assert(false)
//            fatalError()
//        }
    }
}

public extension Array where Element : UIBezierPath {
    func transform(using transform: CGAffineTransform){
        for path in self {
            path.apply(transform)
        }
    }
}

extension CGPath {
    func forEach(callback: @escaping (CGPathElement) -> Void) {
        typealias Callback = (CGPathElement) -> Void

        func apply(info: UnsafeMutableRawPointer?, element: UnsafePointer<CGPathElement>) {
            let callback = UnsafeMutablePointer<Callback>(OpaquePointer(info))
            callback?.pointee(element.pointee)
        }

        var calle = {
            callback($0)
        }

        withUnsafeMutablePointer(to: &calle) { pointer in
            self.apply(info: pointer, function: apply)
        }
    }

    var elementCount: Int {
        var elements: Int = 0
        forEach { (_) in
            elements = elements + 1
        }
        return elements
    }
}
