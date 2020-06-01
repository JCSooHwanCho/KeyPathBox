//
//  FutureBox.swift
//  KeyPathBox
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import Foundation

final class FutureBox<Content, Failure: Error>: KeyPathBoxProtocol {
    private var result: Result<Content,Failure>?
    private let lock = NSRecursiveLock()
    private var watingQueue: [(Result<Content,Failure>) -> Void] = []

    init (_ wantToAccomplish: @escaping (@escaping (Result<Content, Failure>) -> Void) -> Void) {
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

    func initialize(_ complete: @escaping (Result<Content, Failure>) -> Void) {
        if let result = self.result {
            complete(result)
            return
        }

        self.lock.atomicAction {
            self.watingQueue.append(complete)
        }
    }

    subscript<Value>(innerKeyPath keyPath: KeyPath<Content, Value>) -> Value? {
        guard let result = self.result else { return nil }

        switch result {
        case let .success(box):
            return box[keyPath: keyPath]
        case .failure:
            return nil
        }
    }

    subscript<Value>(innerKeyPath keyPath: WritableKeyPath<Content, Value>) -> Value? {
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

extension FutureBox: IndexModifiable where Content: IndexModifiable {
    subscript(maybeInBound index: Content.Index) -> Content.Element? {
        get {
            guard let result = self.result else { return nil }

            switch result {
            case let .success(box):
                return box[maybeInBound: index]
            case .failure:
                return nil
            }
        }
        set {
            guard let result = self.result else { return }

             switch result {
             case var .success(box):
                box[maybeInBound: index] = newValue
                self.result = .success(box)
             case .failure:
                 return
             }
        }
    }
}

extension FutureBox: IndexReferenceable where Content: IndexReferenceable {
    subscript(maybeInBound index: Content.Index) -> Content.Element? {
        guard let result = self.result else { return nil }

        switch result {
        case let .success(box):
            return box[maybeInBound: index]
        case .failure:
            return nil
        }
    }
}
