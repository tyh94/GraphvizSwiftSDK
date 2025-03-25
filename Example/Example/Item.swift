//
//  Item.swift
//  Example
//
//  Created by Татьяна Макеева on 22.03.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
