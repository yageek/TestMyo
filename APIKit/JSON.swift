//
//  JSON.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Foundation

public protocol JSONObject: JSONMarshable, JSONUnmarshable {}

public protocol JSONMarshable {
    associatedtype Raw: Any
    var JSON: Raw { get }
}

public protocol JSONUnmarshable {
    associatedtype Raw: Any
    init?(JSON: Raw)
}
