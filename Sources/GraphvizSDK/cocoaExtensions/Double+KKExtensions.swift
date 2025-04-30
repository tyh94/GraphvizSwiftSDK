//
//  Double+KKExtensions.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

import Foundation

func isDoubleEqual(_ left: Double, _ right: Double, delta: Double = 0.01) -> Bool {
    fabs(left - right) <= delta
}

func isCGFloatEqual(_ left: CGFloat, _  right: CGFloat, delta: CGFloat = 0.01) -> Bool {
    abs(left - right) <= delta
}

extension CGFloat {
    var squared: CGFloat {
        self*self
    }
    var asDouble: Double {
        Double(self)
    }
}

extension Double {
    var asCGFloat: CGFloat {
        CGFloat(self)
    }
}
