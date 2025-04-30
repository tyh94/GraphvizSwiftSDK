//
//  CGRect+KKExtensions.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

extension CGRect {
    init (box: boxf) {
        self.init(x: box.LL.x, y: box.LL.y, width: box.UR.x - box.LL.x, height: box.UR.y - box.LL.y)
    }
}
