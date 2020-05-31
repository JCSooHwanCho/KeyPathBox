//
//  KeyPathBoxContainerProtocol.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation


protocol KeyPathBoxProtocol {
    associatedtype Content

    subscript<Value>(innerKeyPath keyPath: WritableKeyPath<Content, Value>) -> Value? { get set }
    subscript<Value>(innerKeyPath keyPath: KeyPath<Content, Value>) -> Value? { get }
}
