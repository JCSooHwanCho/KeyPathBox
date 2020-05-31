//
//  FutureBox.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation

final class FutureBox<KeyPathBox: SafeArrayProtocol, Failure: Error>: KeyPathBoxProtocol {
    typealias Element = KeyPathBox.Element

    private var result: Result<KeyPathBox,Failure>?
    private let lock = NSRecursiveLock()
    private var watingQueue: [(Result<KeyPathBox,Failure>) -> Void] = []

    init (_ wantToAccomplish: @escaping (@escaping (Result<KeyPathBox, Failure>) -> Void) -> Void) {
        wantToAccomplish { result in
            self.lock.do {
                guard self.result == nil else { return }
                self.result = result

                for waiting in self.watingQueue {
                    waiting(result)
                }

                self.watingQueue.removeAll()
            }
        }
    }

    func initialize(_ complete: @escaping (Result<KeyPathBox, Failure>) -> Void) {
        if let result = self.result {
            complete(result)
            return
        }

        self.lock.do {
            self.watingQueue.append(complete)
        }
    }
}

extension FutureBox: SafeArrayProtocol {
    subscript(index: Int) -> Element? {
        get {
            guard let result = self.result else { return nil }

            switch result {
            case let .success(box):
                return box[index]
            case .failure:
                return nil
            }
        }
        set {
            guard let result = self.result else { return }

             switch result {
             case var .success(box):
                box[index] = newValue
                self.result = .success(box)
             case .failure:
                 return
             }
        }
    }


    subscript<Value>(innerKeyPath keyPath: KeyPath<KeyPathBox, Value>) -> Value? {
        guard let result = self.result else { return nil }

        switch result {
        case let .success(box):
            return box[keyPath: keyPath]
        case .failure:
            return nil
        }
    }

    subscript<Value>(innerKeyPath keyPath: WritableKeyPath<KeyPathBox, Value>) -> Value? {
        get {
            guard let result = self.result else { return nil }

            switch result {
            case let .success(box):
                return box[keyPath: keyPath]
            case .failure:
                return nil
            }
        }
        set {
            guard let result = self.result,
                let newValue = newValue else { return }

             switch result {
             case var .success(box):
                box[keyPath: keyPath] = newValue
                self.result = .success(box)
             case .failure:
                 return
             }
        }
    }
}
