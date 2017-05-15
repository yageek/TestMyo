//
//  APIKitTests.swift
//  APIKitTests
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import XCTest
@testable import APIKit

class APIKitTests: XCTestCase {

    func testDateFormatter() {

        let date = "2016-12-14T22:09:03.611502Z"
        let otherDate = "2016-12-06T10:54:29Z"

        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"

        XCTAssertNotNil(dateFormatter.date(from: date))
        XCTAssertNotNil(dateFormatter.date(from: otherDate))


        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        XCTAssertNotNil(formatter.date(from: otherDate))
        XCTAssertNotNil(formatter.date(from: date))
    }

}
