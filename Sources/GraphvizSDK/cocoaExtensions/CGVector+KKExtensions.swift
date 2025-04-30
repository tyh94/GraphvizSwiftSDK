//
//  CGVector+KKExtensions.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

//https://github.com/raywenderlich/SKTUtils/blob/master/SKTUtils/CGVector%2BExtensions.swift

import CoreGraphics
import Foundation

extension CGVector {
    /**
     * Creates a new CGVector given a CGPoint.
     */
    init(point: CGPoint) {
        self.init(dx: point.x, dy: point.y)
    }
    
    init (from: CGPoint, to: CGPoint) {
        self.init(dx: to.x - from.x, dy: to.y - from.y)
    }
    
    var orthogonalVector: CGVector {
        CGVector(dx: self.dy, dy: self.dx * -1.0)
    }
    
    var opposingVector: CGVector {
        CGVector(dx: -1.0 * self.dx, dy: -1.0 * self.dy )
    }
    
    /**
     * Given an angle in radians, creates a vector of length 1.0 and returns the
     * result as a new CGVector. An angle of 0 is assumed to point to the right.
     */
    init(angle: CGFloat) {
        self.init(dx: cos(angle), dy: sin(angle))
    }
    
    /**
     * Adds (dx, dy) to the vector.
     */
    mutating func offset(dx: CGFloat, dy: CGFloat) -> CGVector {
        self.dx += dx
        self.dy += dy
        return self
    }
    
    /**
     * Returns the length (magnitude) of the vector described by the CGVector.
     */
    func length() -> CGFloat {
        sqrt(dx*dx + dy*dy)
    }
    
    /**
     * Returns the squared length of the vector described by the CGVector.
     */
    func lengthSquared() -> CGFloat {
        dx*dx + dy*dy
    }
    
    /**
     * Normalizes the vector described by the CGVector to length 1.0 and returns
     * the result as a new CGVector.
     public  */
    func normalized() -> CGVector {
        let len = length()
        return len>0 ? self / len : CGVector.zero
    }
    
    /**
     * Normalizes the vector described by the CGVector to length 1.0.
     */
    mutating func normalize() -> CGVector {
        self = normalized()
        return self
    }
    
    /**
     * Calculates the distance between two CGVectors. Pythagoras!
     */
    func distanceTo(_ vector: CGVector) -> CGFloat {
        (self - vector).length()
    }
    
    /**
     * Returns the angle in radians of the vector described by the CGVector.
     * The range of the angle is -π to π; an angle of 0 points to the right.
     */
    var angle: CGFloat {
        atan2(dy, dx)
    }
    
    func angleBetween(other: CGVector) -> CGFloat{
        let diff = self - other
        return diff.angle
    }
    
    func turn (degree: Double) -> CGVector {
        let sinus = sin(degree)
        let cosinus = cos(degree)
        let x2 = cosinus * self.dx - sinus * self.dy
        let y2 = sinus * self.dx + cosinus * self.dy
        return CGVector(dx: x2, dy: y2)
    }
}

let zeroVector = CGVector(dx: 0, dy: 0)

/**
 * Adds two CGVector values and returns the result as a new CGVector.
 */
func + (left: CGVector, right: CGVector) -> CGVector {
    CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

/**
 * Increments a CGVector with the value of another.
 */
func += (left: inout CGVector, right: CGVector) {
    left = left + right
}

/**
 * Subtracts two CGVector values and returns the result as a new CGVector.
 */
func - (left: CGVector, right: CGVector) -> CGVector {
    CGVector(dx: left.dx - right.dx, dy: left.dy - right.dy)
}

/**
 * Decrements a CGVector with the value of another.
 */
func -= (left: inout CGVector, right: CGVector) {
    left = left - right
}

/**
 * Multiplies two CGVector values and returns the result as a new CGVector.
 */
func * (left: CGVector, right: CGVector) -> CGVector {
    CGVector(dx: left.dx * right.dx, dy: left.dy * right.dy)
}

/**
 * Multiplies a CGVector with another.
 */
func *= (left: inout CGVector, right: CGVector) {
    left = left * right
}

/**
 * Multiplies the x and y fields of a CGVector with the same scalar value and
 * returns the result as a new CGVector.
 */
func * (vector: CGVector, scalar: CGFloat) -> CGVector {
    CGVector(dx: vector.dx * scalar, dy: vector.dy * scalar)
}

/**
 * Multiplies the x and y fields of a CGVector with the same scalar value.
 */
func *= (vector: inout CGVector, scalar: CGFloat) {
    vector = vector * scalar
}

/**
 * Divides two CGVector values and returns the result as a new CGVector.
 */
func / (left: CGVector, right: CGVector) -> CGVector {
    CGVector(dx: left.dx / right.dx, dy: left.dy / right.dy)
}

/**
 * Divides a CGVector by another.
 */
func /= (left: inout CGVector, right: CGVector) {
    left = left / right
}

/**
 * Divides the dx and dy fields of a CGVector by the same scalar value and
 * returns the result as a new CGVector.
 */
func / (vector: CGVector, scalar: CGFloat) -> CGVector {
    CGVector(dx: vector.dx / scalar, dy: vector.dy / scalar)
}

/**
 * Divides the dx and dy fields of a CGVector by the same scalar value.
 */
func /= (vector: inout CGVector, scalar: CGFloat) {
    vector = vector / scalar
}

/**
 * Performs a linear interpolation between two CGVector values.
 */
func lerp(start: CGVector, end: CGVector, t: CGFloat) -> CGVector {
    start + (end - start) * t
}
