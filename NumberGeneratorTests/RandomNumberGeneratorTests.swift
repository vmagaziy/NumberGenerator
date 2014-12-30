// Created by Vladimir Magaziy <vmagaziy@gmail.com>

import UIKit
import XCTest

class RandomNumberGeneratorTests: XCTestCase {    
    func testNumberOfRandomNumbers() {
        let numbers = RandomNumberGenerator.generateWithCount(10, max:100, min:1)
        XCTAssertEqual(numbers.count, 10, "")
    }
    
    func testBoundsOfRandomNumbers() {
        let min: UInt = 23
        let max: UInt = 100
        let numbers = RandomNumberGenerator.generateWithCount(10000, max:max, min:min)
        for number in numbers {
            XCTAssertTrue(number >= min && number <= max, "")
        }
    }
}
