//
//  GVGraphvizProperty.swift
//  GraphvizSDK
//
//  Created by Татьяна Макеева on 30.04.2025.
//

@preconcurrency import CGraphvizSDK

@propertyWrapper
public struct GVGraphvizProperty<Key: RawRepresentable<String>, Value> {
    let key: Key
    let defaultValue: Value
    let converterToValue: (String) -> Value
    let converterFromValue: (Value) -> String
    let container: UnsafeMutableRawPointer
    
    public var wrappedValue: Value {
        get {
            guard let cValue = agget(container, cString(key.rawValue)) else {
                return defaultValue
            }
            return converterToValue(String(cString: cValue))
        }
        set {
            agsafeset(container, cString(key.rawValue), cString(converterFromValue(newValue)), "")
        }
    }
    
    public init(
        key: Key,
        defaultValue: Value,
        container: UnsafeMutableRawPointer
    ) where Value == String {
        self.key = key
        self.defaultValue = defaultValue
        self.converterToValue = { $0 }
        self.converterFromValue = { $0 }
        self.container = container
    }
    
    public init(
        key: Key,
        defaultValue: Value,
        container: UnsafeMutableRawPointer
    ) where Value == Float {
        self.key = key
        self.defaultValue = defaultValue
        self.converterToValue = { Value($0) ?? defaultValue }
        self.converterFromValue = { $0.description }
        self.container = container
    }
    
    public init(
        key: Key,
        defaultValue: Value,
        container: UnsafeMutableRawPointer
    ) where Value == Bool {
        self.key = key
        self.defaultValue = defaultValue
        self.converterToValue = { Value($0) ?? defaultValue }
        self.converterFromValue = { $0.description }
        self.container = container
    }
    
    public init(
        key: Key,
        defaultValue: Value,
        container: UnsafeMutableRawPointer
    ) where Value == Double {
        self.key = key
        self.defaultValue = defaultValue
        self.converterToValue = { Value($0) ?? defaultValue }
        self.converterFromValue = { $0.description }
        self.container = container
    }
    
    public init(
        key: Key,
        defaultValue: Value,
        container: UnsafeMutableRawPointer
    ) where Value == Int {
        self.key = key
        self.defaultValue = defaultValue
        self.converterToValue = { Value($0) ?? defaultValue }
        self.converterFromValue = { $0.description }
        self.container = container
    }
}

protocol NumericType: CustomStringConvertible {}

extension GVGraphvizProperty where Value: RawRepresentable, Value.RawValue == String {
    public init(
        key: Key,
        defaultValue: Value,
        container: UnsafeMutableRawPointer
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.converterToValue = { Value(rawValue: $0) ?? defaultValue }
        self.converterFromValue = { $0.rawValue }
        self.container = container
    }
}

extension GVGraphvizProperty where Value == GVColor {
    public init(
        key: Key,
        defaultValue: Value,
        container: UnsafeMutableRawPointer
    ) {
        self.key = key
        self.defaultValue = defaultValue
        self.converterToValue = { Value.fromString($0) }
        self.converterFromValue = { $0.toString }
        self.container = container
    }
}
