//
//  NSRecursiveLock+do.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation

extension NSLocking {
    func atomicAction(_ action: ()->Void) {
        self.lock()
        action()
        self.unlock()
    }

    func atomicRefer<Value>(_ refer: () -> Value) -> Value{
        defer { self.unlock() }
        self.lock()
        return refer()
    }
}
