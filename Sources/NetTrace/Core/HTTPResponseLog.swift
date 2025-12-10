//
//  HTTPResponseLog.swift
//  NetTrace
//
//  Created by Lyubomir Marinov on 4.12.25.
//

import Foundation

public struct HTTPResponseLog: Hashable {
    public let statusCode: Int
    public let headers: [String: String]?
    public let body: Data?
    public let date: Date
    
    public init(response: HTTPURLResponse, data: Data?) {
        self.statusCode = response.statusCode
        self.headers = response.allHeaderFields as? [String: String]
        self.body = data
        self.date = Date()
    }
}
