//
//  Set+KKExtentions.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

import Foundation

extension Set {
    var asArray: [Element] {
        Array(self)
    }
}

extension Array where Element : Hashable {
    var asSet: Set<Element> {
        Set<Element>(self)
    }
}
