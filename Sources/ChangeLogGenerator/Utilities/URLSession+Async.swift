//
//  URLSession+Async.swift
//  
//
//  Created by Mahmood Tahir on 2021-12-09.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum URLSessionError: Error {
    case emptyData
}

extension URLSession {
    /// Perform a data task async which is available down to iOS 13 and macOS 10.15
    /// - Parameter request: the request to perform
    /// - Returns: a data and response object
    public func dataAsync(for request: URLRequest) async throws -> (Data, URLResponse) {
        #if os(macOS) || os(iOS)
            if #available(macOS 12.0, iOS 15.0, watchOS 8.0, tvOS 15.0, *) {
                return try await data(for: request)
            }
            else {
                return try await makeAsync(for: request)
            }
        #else
            return try await makeAsync(for: request)
        #endif
    }

    private func makeAsync(for request: URLRequest) async throws -> (Data, URLResponse) {
        try await withUnsafeThrowingContinuation { continuation in
            let task = dataTask(with: request) { data, response, error in
                if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                }
                else if let error = error {
                    continuation.resume(throwing: error)
                }
                else {
                    continuation.resume(throwing: URLSessionError.emptyData)
                }
            }

            task.resume()
        }
    }
}
