//
//  FutureBox.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation

public final class FutureBox<Content, Failure: Error>: KeyPathBoxProtocol {
    private var result: Result<Content,Failure>?
    private let lock = NSRecursiveLock()
    private var watingQueue: [(Result<Content,Failure>) -> Void] = []

    public init (_ wantToAccomplish: @escaping (@escaping (Result<Content, Failure>) -> Void) -> Void) {
        wantToAccomplish { result in
            self.lock.atomicAction {
                guard self.result == nil else { return }
                self.result = result

                for waiting in self.watingQueue {
                    waiting(result)
                }

                self.watingQueue.removeAll()
            }
        }
    }

    public func sink(_ complete: @escaping (Result<Content, Failure>) -> Void) {
        if let result = self.result {
            complete(result)
            return
        }

        self.lock.atomicAction {
            self.watingQueue.append(complete)
        }
    }

    public subscript<Value>(innerKeyPath keyPath: KeyPath<Content, Value>) -> Value? {
        guard let result = self.result else { return nil }

        switch result {
        case let .success(box):
            return box[keyPath: keyPath]
        case .failure:
            return nil
        }
    }

    public subscript<Value>(innerKeyPath keyPath: WritableKeyPath<Content, Value>) -> Value? {
        get {
            self.lock.atomicRefer {
                guard let result = self.result else { return nil }

                switch result {
                case let .success(box):
                    return box[keyPath: keyPath]
                case .failure:
                    return nil
                }
            }
        }
        set {
            self.lock.atomicAction {
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
}

extension FutureBox {
    func map<T> (_ transform: @escaping (Content) -> T) -> FutureBox<T,Failure> {
        return FutureBox<T, Failure> { complete in
            self.sink { result in
                switch result {
                case let .success(content):
                    complete(.success(transform(content)))
                case let .failure(failure):
                    complete(.failure(failure))
                }
            }
        }
    }

    func receive(on queue: DispatchQueue) -> FutureBox<Content,Failure> {
        return FutureBox<Content, Failure> { complete in
            self.sink { result in
                queue.async {
                    complete(result)
                }
            }
        }
    }
}
