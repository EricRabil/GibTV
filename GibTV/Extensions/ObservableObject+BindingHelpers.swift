//
//  ObservableObject+BindingHelpers.swift
//  GibTV
//
//  Created by Eric Rabil on 10/12/22.
//

import Foundation
import SwiftUI

extension ObservableObject {
    func binding<Key: Hashable, Value>(forDictionary dictionary: ReferenceWritableKeyPath<Self, [Key: Value]>, atKey key: Key, defaultValue: @autoclosure @escaping () -> Value) -> Binding<Value> {
        Binding(get: {
            return self[keyPath: dictionary][key] ?? defaultValue()
        }, set: {
            self[keyPath: dictionary][key] = $0
        })
    }
    
    func binding<Key: Hashable, Value>(forDictionary dictionary: ReferenceWritableKeyPath<Self, [Key: Value]>, atKey key: Key) -> Binding<Value?> {
        Binding(get: {
            return self[keyPath: dictionary][key]
        }, set: {
            self[keyPath: dictionary][key] = $0
        })
    }
}
