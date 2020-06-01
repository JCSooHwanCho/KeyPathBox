//
//  KeyPathBoxTests.swift
//  KeyPathBoxTests
//
//  Created by Joshua on 2020/05/31.
//  Copyright © 2020 Joshua. All rights reserved.
//

import XCTest
@testable import KeyPathBox

class FutureBoxTest: XCTestCase {

    func testInitializingSuccess() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.success(TestModifiable()))
        }

        XCTAssertTrue(futureBox[maybeInBound: 0] == 1)
        XCTAssertTrue(futureBox[maybeInBound: 1] == 2)
        XCTAssertTrue(futureBox[maybeInBound: 2] == 3)
        XCTAssertTrue(futureBox[innerKeyPath: \.immutable] == "immutable")
    }

    func testInitializingFail() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.failure(KeyPathBoxTestError.initializingError))
        }

        XCTAssertTrue(futureBox[maybeInBound: 0] == nil)
        XCTAssertTrue(futureBox[maybeInBound: 1] == nil)
        XCTAssertTrue(futureBox[maybeInBound: 2] == nil)
        XCTAssertTrue(futureBox[innerKeyPath: \.immutable] == nil)
    }

    func testValueChangeSuccess() throws {

        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.success(TestModifiable()))
        }

        futureBox[maybeInBound: 1][keyPath: \.self] = 4
        futureBox[innerKeyPath: \.one] = 5

        XCTAssertTrue(futureBox[innerKeyPath: \.one] == 5)
        XCTAssertTrue(futureBox[maybeInBound: 1][keyPath: \.self] == 4)
    }

    func testValueChangeFailCausedInitializingFail() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.failure(KeyPathBoxTestError.initializingError))
        }

        futureBox[maybeInBound: 1][keyPath: \.self] = 1
        futureBox[innerKeyPath: \.one] = 2

        XCTAssertTrue(futureBox[innerKeyPath: \.one] == nil)
        XCTAssertTrue(futureBox[maybeInBound: 1][keyPath: \.self] == nil)
    }

    func testValueChangeFailCausedOutOfRange() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.success(TestModifiable()))
        }

        futureBox[maybeInBound: 1][keyPath: \.self] = nil

        XCTAssertFalse(futureBox[maybeInBound: 1][keyPath: \.self] == nil)
    }

    func testOptionalBoxChangeSuccess() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.success(TestModifiable()))
        }

        futureBox[maybeInBound: 1][keyPath: \.self] = 4

        XCTAssertTrue(futureBox[maybeInBound: 1][keyPath: \.self] == Optional(4))
    }

    func testOptionalBoxChangeFail() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.success(TestModifiable()))
        }

        futureBox[maybeInBound: 1][keyPath: \.self] = nil

        XCTAssertFalse(futureBox[maybeInBound: 1][keyPath: \.self] == nil)
    }

    func testBoxChangeIndexOutOfRange() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            complete(.success(TestModifiable()))
        }

        let originalBox = futureBox[innerKeyPath: \.self]

        futureBox[maybeInBound: 4][keyPath: \.self] = 4

        XCTAssertTrue(futureBox[innerKeyPath: \.self] == originalBox)
    }

    func testFutureBoxInitializingOnBackgroundSuccess() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            DispatchQueue.global().asyncAfter(deadline: .now()+2) {
                complete(.success(TestModifiable()))
            }
        }

        let expectation = XCTestExpectation(description: "futureBoxInitializing")

        futureBox.initialize { result in

            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testFutureBoxInitializingOnBackgroundFail() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            DispatchQueue.global().asyncAfter(deadline: .now()+2) {
                complete(.failure(KeyPathBoxTestError.initializingError))
            }
        }

        let expectation = XCTestExpectation(description: "futureBoxInitializing")

        futureBox.initialize { result in

            switch result {
            case .success:
                XCTFail()
            case .failure:
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testFutureBoxInitializingOnBackgroundInitializingAfterSuccess() throws {
        let futureBox = FutureBox<TestModifiable, Error> { complete in
            DispatchQueue.global().asyncAfter(deadline: .now()+2) {
                complete(.success(TestModifiable()))
            }
        }

        let expectation = XCTestExpectation(description: "futureBoxInitializing")

        futureBox.initialize { _ in
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 5)

        futureBox.initialize { _ in
            XCTAssertTrue(Thread.isMainThread) 
        }
    }

    func testFutureBoxReferenceWithoutInitialization() throws {
        let futureBox = FutureBox<TestModifiable, Error> { _ in

        }

        XCTAssertTrue(futureBox[innerKeyPath: \.self] == nil)
        XCTAssertTrue(futureBox[maybeInBound: 0] == nil)
        XCTAssertTrue(futureBox[maybeInBound: 1] == nil)
        XCTAssertTrue(futureBox[maybeInBound: 2] == nil)
        XCTAssertTrue(futureBox[innerKeyPath: \.immutable] == nil)
    }

    func testFutureBoxChangeValueWithoutInitialization() throws {
        let futureBox = FutureBox<TestModifiable, Error> { _ in

        }

        futureBox[maybeInBound: 1][keyPath: \.self] = 4

        XCTAssertTrue(futureBox[innerKeyPath: \.self] == nil)
        XCTAssertTrue(futureBox[maybeInBound: 1] == nil)
    }

    func testFutureBoxReferenceableInitializationSuccess() throws {
        let futureBox = FutureBox<TestReferenceable, Error> { complete in
            complete(.success(TestReferenceable()))
        }

        XCTAssertTrue(futureBox[innerKeyPath: \.self] != nil)
    }

    func testFutureBoxReferenceableInitializationFailure() throws {
        let futureBox = FutureBox<TestReferenceable, Error> { complete in
            complete(.failure(KeyPathBoxTestError.initializingError))
        }

        XCTAssertTrue(futureBox[innerKeyPath: \.self] == nil)
    }

    func testFutureBoxReferenceableReferSuccess() throws {
        let futureBox = FutureBox<TestReferenceable, Error> { complete in
            complete(.success(TestReferenceable()))
        }

        XCTAssertTrue(futureBox[maybeInBound: 0] == 1)
        XCTAssertTrue(futureBox[innerKeyPath: \.self]?[maybeInBound: 0] == 1)
    }

    func testFutureBoxReferenceableReferSuccessFailure() throws {
        let futureBox = FutureBox<TestReferenceable, Error> { complete in
            complete(.failure(KeyPathBoxTestError.initializingError))
        }

        XCTAssertTrue(futureBox[maybeInBound: 0] == nil)
        XCTAssertTrue(futureBox[innerKeyPath: \.self]?[maybeInBound: 0] == nil)
    }
}
