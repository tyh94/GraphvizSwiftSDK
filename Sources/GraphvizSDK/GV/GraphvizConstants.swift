//
//  GraphvizConstants.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

enum GraphvizError: Error {
    case noPath
    case headTailMissing
}

///Global Graphviz Context.
///To be set at program start and freed and progam end
nonisolated(unsafe) let gblGVContext: GVGlobalContextPointer = loadGraphvizLibraries()

public typealias CHAR = UnsafeMutablePointer<Int8>
public typealias CHAR_ARRAY = UnsafeMutablePointer<UnsafeMutablePointer<Int8>>
public typealias GVSplines = UnsafeMutablePointer<splines>
public typealias GVBezier = UnsafeMutablePointer<bezier>
public typealias GVPixel = CGFloat
public typealias GVGlobalContextPointer = UnsafeMutablePointer<GVC_t>
