//
//  GVEdge.swift
//  SwiftGraphiz
//
//  Created by Klaus Kneupner on 13/01/2019.
//  Copyright © 2019 Klaus Kneupner. All rights reserved.
//

@preconcurrency import CGraphvizSDK
import UIKit

public typealias GVEdge = UnsafeMutablePointer<Agedge_t>

public extension UnsafeMutablePointer where Pointee == Agedge_t {
    var labelPos: CGPoint? {
        if let lPos = ed_lp(self) {
            return convertZeroPointToNil(CGPoint(gvPoint: lPos.pointee))
        }
        return nil
    }
    var headLabelPos: CGPoint? {
        if let lPos = ed_head_lp(self) {
            return convertZeroPointToNil(CGPoint(gvPoint: lPos.pointee))
        }
        return nil
    }
    var tailLabelPos: CGPoint? {
        if let lPos = ed_tail_lp(self) {
            return convertZeroPointToNil(CGPoint(gvPoint: lPos.pointee))
        }
        return nil
    }
    
    var labelText: String? {
        if let text = ed_label_text(self) {
            return String(cString: text)
        }
        return nil
    }
    
    var headLabelText: String? {
        if let text = ed_head_label_text(self) {
            return String(cString: text)
        }
        return nil
    }
    
    var tailLabelText: String? {
        if let text = ed_tail_label_text(self) {
            return String(cString: text)
        }
        return nil
    }
    
    var spline: GVSplines? {
        ed_spl(self)
    }
    
    func getPath() throws -> [CGPoint]  {
        guard let spline = spline, let bezier = spline.pointee.list else {  //warning! this could be an array, see warning log in var spine: GVSlines?
            throw GraphvizError.noPath
        }
        let nrPoints = Int(bezier.pointee.size)
        let pointer = UnsafeRawPointer(bezier.pointee.list).bindMemory(to: pointf_s.self, capacity: nrPoints)
        var points: [pointf_s] = []
        for i in 0..<nrPoints {
            points.append(pointer[i])
        }
        return points.map(pointTransformGraphvizToCGPoint)
    }
    
    var arrowHead: CGPoint? {
        guard let spline = spline, let bezier = spline.pointee.list else {
            return nil
        }
        if bezier.pointee.eflag == 0 {
            return nil
        }
        let result = bezier.pointee.ep
        return pointTransformGraphvizToCGPoint(result)
    }
    
    var arrowTail: CGPoint? {
        guard let spline = spline, let bezier = spline.pointee.list else {
            return nil
        }
        if bezier.pointee.sflag == 0 {
            return nil
        }
        let result = bezier.pointee.sp
        return pointTransformGraphvizToCGPoint(result)
   
    }
    
    var headPortPos: CGPoint {
        pointTransformGraphvizToCGPoint(ed_headPort_pos(self))
    }
    
    var tailPortPos: CGPoint {
        pointTransformGraphvizToCGPoint(ed_tailPort_pos(self))
    }
}

