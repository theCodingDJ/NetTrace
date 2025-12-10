//
//  HTTPRequestLog.swift
//  NetTrace
//
//  Created by Lyubomir Marinov on 4.12.25.
//

import Foundation

public struct HTTPRequestLog: Identifiable, Hashable {
    public let id: String
    public let url: URL?
    public let method: String?
    public let headers: [String: String]?
    public let body: Data?
    public let date: Date
    
    public var response: HTTPResponseLog?
    public var error: ErrorLog?
    public var duration: TimeInterval?
    
    public init(id: String, request: URLRequest) {
        self.id = id
        self.url = request.url
        self.method = request.httpMethod
        self.headers = request.allHTTPHeaderFields
        self.body = request.httpBody
        self.date = Date()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: HTTPRequestLog, rhs: HTTPRequestLog) -> Bool {
        lhs.id == rhs.id
    }
}
