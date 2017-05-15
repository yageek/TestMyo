//
//  API.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import Foundation
import ProcedureKit

public struct API {
    public static var APIKey: String?
    public static let BaseHost = "https://api-staging.myotest.cloud/api"
    public static var Token: String? = ""
    
    private static let TimestampFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        let enUSPosixLocale = Locale(identifier: "en_US_POSIX")
        dateFormatter.locale = enUSPosixLocale
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return dateFormatter
    }()

    private static let ISODateFormatter = ISO8601DateFormatter()

    public static func date(from: String) -> Date? {

        if let date = API.TimestampFormatter.date(from: from) {
            return date
        }

        return API.ISODateFormatter.date(from: from)

    }

    public static let BaseURL  = Foundation.URL(string:BaseHost)!
}

public enum Resource<T> {
    case none
    case single(T)
    case collection(Array<T>)
}

public protocol Endpoint {
    
    var baseURL: URL { get }
    var parameters: [String: Any] { get }
    var path: String { get }
    var method: String { get }
}

public extension Endpoint {

    var baseURL: URL {
        return API.BaseURL
    }

}
