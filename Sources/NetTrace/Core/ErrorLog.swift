//
//  ErrorLog.swift
//  NetTrace
//
//  Created by Lyubomir Marinov on 4.12.25.
//

import Foundation

public struct ErrorLog: Hashable {
    public let localizedDescription: String
    public let domain: String
    public let code: Int
    
    public init(error: Error) {
        self.localizedDescription = error.localizedDescription
        let nsError = error as NSError
        self.domain = nsError.domain
        self.code = nsError.code
    }
}
