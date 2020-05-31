//
//  NSRecursiveLock+do.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation

extension NSRecursiveLock {
    func `do`(_ action: ()->Void) {
        self.lock()
        action()
        self.unlock()
    }
}
