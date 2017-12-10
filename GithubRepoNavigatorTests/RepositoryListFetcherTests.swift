//
//  RepositoryListFetcherTests.swift
//  GithubRepoNavigatorTests
//
//  Created by Won Cheul Seok on 2017. 12. 10..
//  Copyright © 2017년 Evan Seok. All rights reserved.
//

import XCTest
@testable import GithubRepoNavigator
class RepositoryListFetcherTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testBeginFetch() {
        let expect = expectation(description: "a")
        RepositoryListFetcher.shared.beginFetch { (results, error) in
            XCTAssertNil(error)
            XCTAssertNotNil(results)
            XCTAssertGreaterThan(results!.count, 0)
            expect.fulfill()
        }
        self.waitForExpectations(timeout: 5.0) { (error) in
            XCTAssertNil(error)
        }
    }
    
}