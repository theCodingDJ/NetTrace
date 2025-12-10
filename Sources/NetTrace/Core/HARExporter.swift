//
//  HARExporter.swift
//  NetTrace
//
//  Created by Lyubomir Marinov on 10.12.25.
//

import Foundation

public enum HARExportError: LocalizedError {
    case emptyList
}

public class HARExporter {
    
    func exportList(_ requests: [HTTPRequestLog], fileName: String) throws -> URL {
        
        guard requests.isEmpty == false else {
            throw HARExportError.emptyList
        }
        
        let harData = try generateHARFile(from: requests)
        
        // Create temporary file
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        try harData.write(to: fileURL)
        return fileURL
    }
    
    private func generateHARFile(from requests: [HTTPRequestLog]) throws -> Data {
        let har: [String: Any] = [
            "log": [
                "version": "1.2",
                "creator": [
                    "name": "NetTrace",
                    "version": "1.0.0"
                ],
                "entries": requests.map { convertToHAREntry($0) }
            ]
        ]
        
        return try JSONSerialization.data(withJSONObject: har, options: [.prettyPrinted, .sortedKeys])
    }
    
    private func convertToHAREntry(_ request: HTTPRequestLog) -> [String: Any] {
        var entry: [String: Any] = [:]
        
        // Timestamps
        let startedDateTime = ISO8601DateFormatter().string(from: request.date)
        entry["startedDateTime"] = startedDateTime
        
        // Time (in milliseconds)
        let time = (request.duration ?? 0) * 1000
        entry["time"] = time
        
        // Request
        var harRequest: [String: Any] = [
            "method": request.method ?? "GET",
            "url": request.url?.absoluteString ?? "",
            "httpVersion": "HTTP/1.1",
            "headers": convertHeaders(request.headers),
            "queryString": extractQueryString(from: request.url),
            "cookies": [],
            "headersSize": -1,
            "bodySize": request.body?.count ?? -1
        ]
        
        if let body = request.body {
            harRequest["postData"] = convertPostData(body, headers: request.headers)
        }
        
        entry["request"] = harRequest
        
        // Response
        if let response = request.response {
            let harResponse: [String: Any] = [
                "status": response.statusCode,
                "statusText": HTTPURLResponse.localizedString(forStatusCode: response.statusCode),
                "httpVersion": "HTTP/1.1",
                "headers": convertHeaders(response.headers),
                "cookies": [],
                "content": convertContent(response.body, headers: response.headers),
                "redirectURL": "",
                "headersSize": -1,
                "bodySize": response.body?.count ?? -1
            ]
            
            entry["response"] = harResponse
        } else {
            // No response (error or still loading)
            entry["response"] = [
                "status": 0,
                "statusText": "",
                "httpVersion": "HTTP/1.1",
                "headers": [],
                "cookies": [],
                "content": [
                    "size": 0,
                    "mimeType": "text/plain"
                ],
                "redirectURL": "",
                "headersSize": -1,
                "bodySize": -1
            ]
        }
        
        // Cache
        entry["cache"] = [:]
        
        // Timings
        entry["timings"] = [
            "send": 0,
            "wait": time,
            "receive": 0
        ]
        
        return entry
    }
    
    private func convertHeaders(_ headers: [String: String]?) -> [[String: String]] {
        guard let headers = headers else { return [] }
        return headers.map { ["name": $0.key, "value": $0.value] }
    }
    
    private func extractQueryString(from url: URL?) -> [[String: String]] {
        guard let url = url,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return []
        }
        
        return queryItems.map { item in
            ["name": item.name, "value": item.value ?? ""]
        }
    }
    
    private func convertPostData(_ data: Data, headers: [String: String]?) -> [String: Any] {
        var postData: [String: Any] = [:]
        
        // Determine mime type from headers
        let mimeType = headers?["Content-Type"] ?? "application/octet-stream"
        postData["mimeType"] = mimeType
        
        // Try to convert to text
        if let text = String(data: data, encoding: .utf8) {
            postData["text"] = text
        } else {
            // Fallback to base64
            postData["text"] = data.base64EncodedString()
            postData["encoding"] = "base64"
        }
        
        return postData
    }
    
    private func convertContent(_ data: Data?, headers: [String: String]?) -> [String: Any] {
        var content: [String: Any] = [:]
        
        guard let data = data else {
            content["size"] = 0
            content["mimeType"] = "text/plain"
            return content
        }
        
        content["size"] = data.count
        
        // Determine mime type from headers
        let mimeType = headers?["Content-Type"] ?? "application/octet-stream"
        content["mimeType"] = mimeType
        
        // Try to convert to text
        if let text = String(data: data, encoding: .utf8) {
            content["text"] = text
        } else {
            // Fallback to base64
            content["text"] = data.base64EncodedString()
            content["encoding"] = "base64"
        }
        
        return content
    }
}
