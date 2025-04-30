//
//  GVNode.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

typealias GVNode = UnsafeMutablePointer<Agnode_t>

extension UnsafeMutablePointer where Pointee == Agnode_t  {

    var pos: CGPoint {
        let s = nd_coord(self)
        return CGPoint(gvPoint: s)
    }
    
    var width: CGFloat {
        let s = nd_width(self)
        return CGFloat(s) * pointsPerInch
    }
    
    var height: CGFloat {
        let s = nd_height(self)
        return CGFloat(s) * pointsPerInch
    }
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    var rect: CGRect {
        let mid = self.pos
        let w = self.width
        let h = self.height
        return CGRect(midPoint: mid, size: CGSize(width: w, height: h))
    }
    
    var nodeType: GVNodeShape? {
        guard let shape = nd_shape(self),
              let shapeName = shape.pointee.name else {
            return nil
        }
        
        let type = String(cString: shapeName)
        
        return GVNodeShape(rawValue: type)
    }
    
    var polygon: polygon_t? {
        guard let shapeInfoPtr = nd_shape_info(self) else {
            return nil
        }
        return shapeInfoPtr.assumingMemoryBound(to: polygon_t.self).pointee
    }
}

extension CGRect{
    init(midPoint: CGPoint, size: CGSize) {
        self.init(x: midPoint.x - size.width / 2, y: midPoint.y - size.height / 2, width: size.width, height: size.height)
    }
}
