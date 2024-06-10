//
//  APIManager.swift
//  AdsUser
//
//  Created by Victor Chernykh on 12.11.2022.
//

import Foundation

/// Protocol for API Manager.
public protocol APIManagerProtocol {
    func perform(
		_ request: RequestProtocol,
		with authToken: String?
	) async throws -> (Data, HTTPURLResponse)
}

/// API request manager.
struct APIManager: APIManagerProtocol {
    // MARK: - Stored properties
    private let urlSession: URLSession

    // MARK: - Init
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    /// Executes a network request.
    /// - Parameters:
    ///   - request: Url request.
    ///   - accessToken: Secret access token.
	/// - Throws: If something went wrong.
    /// - Returns: Tuple with data and response.
    func perform(
		_ request: RequestProtocol,
		with accessToken: String? = nil
	) async throws -> (Data, HTTPURLResponse) {
        let urlRequest: URLRequest = try request.createURLRequest(with: accessToken)
		let (data, response): (Data, URLResponse) = try await urlSession.data(for: urlRequest)
		guard let response: HTTPURLResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidServerResponse
        }
        return (data, response)
    }
}
