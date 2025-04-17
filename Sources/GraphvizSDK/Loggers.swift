//
//  Loggers.swift
//  GoutTracker
//
//  Created by Татьяна Макеева on 04.01.2025.
//

import OSLog
import SwiftUI

extension Logger {
    private static let subsystem = Bundle.main.bundleIdentifier!
    static let graphviz = Logger(subsystem: subsystem, category: "graphviz")
    
    static func viewLogger(_ view: any View.Type) -> Logger {
        Logger(subsystem: subsystem, category: "viewui-\(view.self)")
    }
}

extension Logger {
    func error(error: Error) {
        self.error("\(error.localizedDescription, privacy: .public)")
    }
    
    func debug(message: String) {
        self.debug("\(message)")
    }
    
    func info(message: String) {
        self.info("\(message)")
    }
    
    func warning(message: String) {
        self.warning("\(message)")
    }
}
