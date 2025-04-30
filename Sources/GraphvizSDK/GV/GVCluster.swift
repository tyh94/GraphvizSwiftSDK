//
//  GVCluster.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

import Foundation
@preconcurrency import CGraphvizSDK

typealias GVCluster = GVGraph

extension UnsafeMutablePointer where Pointee == Agraph_t {
    var labelPos: CGPoint? { //lp
        if let lPos = gd_lp(self) {
            return convertZeroPointToNil(CGPoint(gvPoint: lPos.pointee))
        }
        return nil
    }
    
    var labelSize: CGSize? { //lsize
        if let lPos = gd_lsize(self) {
            return CGSize(gvPoint: lPos.pointee).convertZeroSizeToNil()
        }
        return nil
    }
    
    var rect: CGRect {
        let box = gd_bb (self)
        return CGRect(box: box)
    }
    
    var labelText: String? {
        if let text = gd_label_text(self) {
            return String(cString: text)
        }
        return nil
    }
}

