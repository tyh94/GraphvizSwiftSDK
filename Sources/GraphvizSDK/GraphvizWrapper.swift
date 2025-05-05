//
//  GraphvizWrapper.swift
//  graphvizTest
//
//  Created by Klaus Kneupner on 3/2/17.
//  Copyright © 2017 Klaus Kneupner. All rights reserved.
//

@preconcurrency import CGraphvizSDK
import Foundation

public enum GVModelDirection: String {
    case towardsLeft = "RL"
    case towardsRight = "LR"
    case towardsTop = "TB"
    case towardsBottom = "BT"
    
    public var isVertical: Bool{
        return self == .towardsTop || self == .towardsBottom
    }
    
    public var isHorizontal: Bool{
        return self == .towardsLeft || self == .towardsRight
    }
    
    var graphvizTailPort: String {
        switch self {
        case .towardsLeft:
            return "w"
        case .towardsBottom:
            return "s"
        case .towardsRight:
            return "e"
        case .towardsTop:
            return "n"
        }
    }
    
    public var graphvizHeadPort: String {
        switch self {
        case .towardsLeft:
            return "e"
        case .towardsBottom:
            return "n"
        case .towardsRight:
            return "w"
        case .towardsTop:
            return "s"
        }
    }
    
    public func isOpposite(other: GVModelDirection) -> Bool {
        return other == self.opposite
    }
    
    public var opposite : GVModelDirection {
        switch self {
        case .towardsLeft:
            return  .towardsRight
        case .towardsBottom:
            return .towardsTop
        case .towardsRight:
            return  .towardsLeft
        case .towardsTop:
            return .towardsBottom
        }
    }
    
    public func isSameDirection(other: GVModelDirection) -> Bool {
        switch self {
        case .towardsLeft:
            return other == .towardsLeft
        case .towardsBottom:
            return other == .towardsBottom
        case .towardsRight:
            return other == .towardsRight
        case .towardsTop:
            return other == .towardsTop
        }
    }
    
    public func is90Degrees(to: GVModelDirection) -> Bool {
        switch self {
        case .towardsLeft:
            return to == .towardsBottom
        case .towardsBottom:
            return to == .towardsRight
        case .towardsRight:
            return to == .towardsTop
        case .towardsTop:
            return to == .towardsLeft
        }
    }
}

public enum GVClusterLabelPos: Int {
    case topLeft = 0
    case topRight
    case bottomLeft
    case bottomRight
}

/// Make Graphviz more chatty. Call only if needed
/// Based on http://stackoverflow.com/questions/29469158/interact-with-legacy-c-terminal-app-from-swift
public func verboseGraphviz() {
    //        let args = ["dot", "-v", "-llibvplugin_dot_layout.6.dylib"]
    let args = ["dot", "-v"]
    // Create [UnsafeMutablePointer<Int8>]:
    var cargs = args.map {
        strdup($0)
        } + [nil]
    // Call C function:
    _ = gvParseArgs(gblGVContext, Int32(args.count), &cargs)
    // Free the duplicated strings:
    for ptr in cargs {
        if let ptr = ptr {
            free(ptr)
        }
    }
}


/// Needs to be called once before closing down the application
public func finishGraphviz() {
    gvFreeContext(gblGVContext)
}

/// Taking a string and creating a `char*` for calling a C function
///
/// **WARNING**
///   1. Don't destroy the orignal string before the result is handed over to the C funtion.
///   2. Don't use it if the String reference is kept on C side.
func cString(_ s: String) -> CHAR {
    UnsafeMutablePointer<Int8>(mutating: (s as NSString).utf8String!)
}

public typealias GVParams = [GVParameter: String]
