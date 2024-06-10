//
//  RequestProtocol.swift
//  AdsUser
//
//  Created by Victor Chernykh on 12.11.2022.
//

import Foundation

/// Protocol for request data.
public protocol RequestProtocol {
	var domain: Domain { get }
    var path: String { get }
    var requestType: RequestMethod { get }

    var isNeedAccessToken: Bool { get }
    var headers: [String: String] { get }
    var body: Codable? { get }
    /// Query params
    var urlParams: [String: String?] { get }
}

// MARK: - Default RequestProtocol
public extension RequestProtocol {
    var isNeedAccessToken: Bool {
        true
    }

    var body: Codable? {
        nil
    }

    var headers: [String: String] {
        [:]
    }

    var urlParams: [String: String?] {
        [:]
    }

	/// Creates URl from request params.
	///
	/// - Returns: URL for request.
	func createURL() throws -> URL {
		var components: URLComponents = .init()
		components.scheme = domain.scheme
		components.host = domain.host
		components.port = domain.port
		components.path = path

		if !urlParams.isEmpty {
			components.queryItems = urlParams.map {
				URLQueryItem(name: $0, value: $1)
			}
		}

		guard let url: URL = components.url else {
			throw NetworkError.invalidURL
		}
		return url
	}

	/// Creates `URLRequest` from request params with auth token.
	///
	/// - Parameter authToken: secret token.
	/// - Returns: URLRequest.
    func createURLRequest(with authToken: String? = nil) throws -> URLRequest {
		let url: URL = try createURL()

		var urlRequest: URLRequest = .init(url: url)
        urlRequest.httpMethod = requestType.rawValue

		if requestType == .GET {
			urlRequest.cachePolicy = .useProtocolCachePolicy
		} else {
			urlRequest.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
		}

        if !headers.isEmpty {
            urlRequest.allHTTPHeaderFields = headers
        }

        if isNeedAccessToken, let authToken {
            urlRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body {
			let encoder: JSONEncoder = .init()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(body)
        }

        return urlRequest
    }
}
