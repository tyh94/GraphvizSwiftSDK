//
//  CGSize+KKExtensions.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

extension CGSize {
    var isFinite: Bool {
        width.isFinite && height.isFinite
    }
    
    init (gvPoint: pointf_s) {
        self.init(width: CGFloat(gvPoint.x), height: CGFloat(gvPoint.y))
        assert (isFinite)
    }
    
    func convertZeroSizeToNil(precision: CGFloat = 0.1) -> CGSize? {
        if self.area < precision {
            return nil
        }
        return self
    }
    
    var area: CGFloat {
        width * height
    }
    
    func hasAtLeastSize (_ minSize: CGSize) -> Bool {
        self.width >= minSize.width && self.height >= minSize.height
    }
    
    func restrictTo (maxSize: CGSize) -> CGSize {
        CGSize(width: min(self.width, maxSize.width), height: min(self.height, maxSize.height))
    }
}


func convertZeroSizeToNil(_ gvSize: CGSize, precision: CGFloat = 0.1) -> CGSize? {
    gvSize.convertZeroSizeToNil(precision:precision)
}

