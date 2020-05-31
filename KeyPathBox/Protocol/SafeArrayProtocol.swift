//
//  KeyPathBoxProtocol.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation

protocol SafeArrayProtocol {
    associatedtype Element

    subscript(maybeInBound index: Int) -> Self.Element? { get set }
}
