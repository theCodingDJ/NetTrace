//
//  NetRecorder.swift
//  NetTrace
//
//  Created by Lyubomir Marinov on 4.12.25.
//

import Foundation

@MainActor
public class NetRecorder {
    public static let shared = NetRecorder()
    
    var requests: [HTTPRequestLog] = []
    
    private init() {}
    
    public func record(id: String, request: URLRequest) {
        let log = HTTPRequestLog(id: id, request: request)
        requests.insert(log, at: 0)
        notifyChange()
    }
    
    public func record(
        response: URLResponse?,
        data: Data?,
        error: Error?,
        forRequestId id: String
    ) {
        guard let index = requests.firstIndex(where: { $0.id == id }) else { return }
        
        var log = requests[index]
        log.duration = Date().timeIntervalSince(log.date)
        
        if let error {
            log.error = ErrorLog(error: error)
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            log.response = HTTPResponseLog(response: httpResponse, data: data)
        }
        
        requests[index] = log
        notifyChange()
    }
    
    public func clear() {
        requests.removeAll()
        notifyChange()
    }
    
    // MARK: - Find Requests functions
    
    public func findRequests(where filtering: (HTTPRequestLog) -> Bool) -> [HTTPRequestLog] {
        requests.filter(filtering)
    }
    
    public func findRequests(byPath path: String) -> [HTTPRequestLog] {
        findRequests { $0.url?.pathExtension.contains(path) ?? false }
    }
    
    public func findRequests(byStatusCode statusCode: Int) -> [HTTPRequestLog] {
        findRequests { $0.response?.statusCode == statusCode }
    }
    
    public func findRequests(byMethod method: String) -> [HTTPRequestLog] {
        findRequests { $0.method == method }
    }
    
    
    private func notifyChange() {
        NotificationCenter.default.post(
            name: NSNotification.Name("NetTraceRequestsChanged"),
            object: nil
        )
    }
}
