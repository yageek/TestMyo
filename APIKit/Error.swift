//
//  Error.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Foundation

public enum APIError: Error {
    case unmarshalError
    case apiErrorCode
    case urlCreation
    case fileError
}
