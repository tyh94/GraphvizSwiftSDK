//
//  GVGraphType.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

public enum GVGraphType {
    case nonStrictDirected
    case strictDirected
    case nonStrictNonDirected
    case strictNonDirected
    
    public var graphvizValue: Agdesc_t {
        switch self {
        case .nonStrictDirected: return Agdirected
        case .strictDirected : return Agstrictdirected
        case .nonStrictNonDirected: return Agundirected
        case .strictNonDirected: return Agstrictundirected
        }
    }
    
    public var isStrict: Bool {
        switch self {
        case .nonStrictDirected, .nonStrictNonDirected : return false
        case .strictDirected, .strictNonDirected : return true
        }
    }
    
    public var isDirected: Bool {
        switch self {
        case .nonStrictDirected, .strictDirected : return true
        case .nonStrictNonDirected, .strictNonDirected : return false
        }
    }
}
