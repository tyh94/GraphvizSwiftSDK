//
//  Graph+Rendering.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 04.05.2025.
//

import Foundation
import OSLog

extension Graph {
    public func render(using layout: GVLayout) throws -> GraphUI {
        try RendererSwiftUI(layout: layout).layout(graph: self)
    }
    
    private var userPath: String {
        let simulatorPath = (NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true) as [String]).first!
        let simulatorPathComponents = URL(string: simulatorPath)!.pathComponents.prefix(3).filter { $0 != "/" }
        let userPath = simulatorPathComponents.joined(separator: "/")
        return userPath
    }
    
    public func log() {
        do {
            let str = try RendererString(layout: .dot).layout(graph: self)
            
#if targetEnvironment(simulator)
            let folderPath = "/\(userPath)/Desktop/FamilyBookLogs/"
            let filePath = folderPath + "tree.txt"
            let data = str.data(using: .utf8)
            try? FileManager.default.createDirectory(atPath: folderPath, withIntermediateDirectories: true, attributes: nil)
            FileManager.default.createFile(
                atPath: filePath,
                contents: data,
                attributes: [:]
            )
            Logger.graphviz.debug(message: "Graph saved to: \(filePath)")
#else
            Logger.graphviz.debug(message: "==========================")
            Logger.graphviz.debug(message: str)
            Logger.graphviz.debug(message: "==========================")
#endif
            
        } catch {
            Logger.graphviz.error(error: error)
        }
    }
}
