//
//  GVGraph.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 02.04.2025.
//

@preconcurrency import CGraphvizSDK
import Foundation

public typealias GVGraph = UnsafeMutablePointer<Agraph_t>

struct AGWriteWrongEncoding: Error { }
struct CannotOpenFileDescriptor: Error { }

extension UnsafeMutablePointer where Pointee == Agraph_t {
    
    /// adapted from: https://stackoverflow.com/questions/59653517/how-to-use-file-descriptor-to-divert-write-to-file-in-swift/59654364#59654364
    var asString: String? {
        let pipe = Pipe()
        do {
            try use(fileDescriptor: pipe.fileHandleForWriting.fileDescriptor, mode: "w") { filePointer in
                agwrite(self, filePointer)
            }
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            guard let output = String(data: data, encoding: .utf8) else {
                return nil
            }
            return output
        } catch {
            return nil
        }
    }
    
    var boundingBox: boxf {
        gd_bb(self)
    }
    
    var height: CGFloat {
        CGFloat(boundingBox.UR.y)
    }
    
    var width: CGFloat {
        CGFloat(boundingBox.UR.x)
    }
    
    var size: CGSize {
        CGSize(width: width, height: height)
    }
    
    func unflatten(doFan: Bool = false, maxMinlen : Int32 = 0, chainLimit : Int32 = 0) {
        agUnflatten(self,doFan ? 1 : 0, maxMinlen ,chainLimit )
    }
}

@discardableResult
fileprivate func use<R>(
    fileDescriptor: Int32,
    mode: UnsafePointer<Int8>!,
    closure: (UnsafeMutablePointer<FILE>) throws -> R
) throws -> R {
    // Should prob remove this `!`, but IDK what a sensible recovery mechanism would be.
    guard let filePointer = fdopen(fileDescriptor, mode) else {
        throw CannotOpenFileDescriptor()
    }
    defer {
        fclose(filePointer)
    }
    return try closure(filePointer)
}
