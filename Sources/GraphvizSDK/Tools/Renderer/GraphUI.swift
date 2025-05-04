//
//  GraphUI.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//


import Foundation
import SwiftUI
@preconcurrency import CGraphvizSDK
import OSLog

public struct GraphUI {
    let nodes: [NodeUI]
    let edges: [EdgeUI]
}