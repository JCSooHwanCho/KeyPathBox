//
//  TestBox.swift
//  KeyPathBoxTests
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

@testable import KeyPathBox

struct TestModifiable: IndexModifiable, Equatable {
    subscript(maybeInBound index: Int) -> Int? {
        get {
            if index == 0 {
                return one
            }

            if index == 1 {
                return two
            }

            if index == 2 {
                return three
            }

            return nil
        }
        set(newValue) {

            guard let newValue = newValue else { return }
            if index == 0 {
                one = newValue
            }

            if index == 1 {
                two = newValue
            }

            if index == 2 {
                three = newValue
            }
        }
    }

    var one: Int = 1
    var two: Int = 2
    var three: Int = 3
    let immutable: String = "immutable"
}

struct TestOptionalModifiable: IndexModifiable {
    subscript(maybeInBound index: Int) -> Int?? {
        get {
            if index == 0 {
                return one
            }

            if index == 1 {
                return two
            }

            if index == 2 {
                return three
            }

            return nil
        }

        set(newValue) {

            guard let newValue = newValue else { return }
            if index == 0 {
                one = newValue
            }

            if index == 1 {
                two = newValue
            }

            if index == 2 {
                three = newValue
            }
        }
    }

    var one: Int? = 1
    var two: Int? = 2
    var three: Int? = 3
}

struct TestReferenceable: IndexReferenceable, Equatable {
    subscript(maybeInBound index: Int) -> Int? {
        get {
            if index == 0 {
                return one
            }

            if index == 1 {
                return two
            }

            if index == 2 {
                return three
            }

            return nil
        }
        set(newValue) {

            guard let newValue = newValue else { return }
            if index == 0 {
                one = newValue
            }

            if index == 1 {
                two = newValue
            }

            if index == 2 {
                three = newValue
            }
        }
    }

    var one: Int = 1
    var two: Int = 2
    var three: Int = 3
    let immutable: String = "immutable"
}
