//
//  KeyPathBoxProtocol.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation

public protocol IndexReferenceable {
    associatedtype Element
    associatedtype Index
    subscript(maybeInBound index: Index) -> Self.Element? { get }
}

public protocol IndexModifiable {
    associatedtype Element
    associatedtype Index
    subscript(maybeInBound index: Index) -> Self.Element? { get set }
}
