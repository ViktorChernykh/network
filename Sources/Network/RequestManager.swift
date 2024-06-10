//
//  RequestManager.swift
//  AdsUser
//
//  Created by Victor Chernykh on 12.11.2022.
//

import Foundation
import KeyChaining
import FullErrorModel

/// Protocol for RequestManager.
public protocol RequestManagerProtocol {
	var apiManager: APIManagerProtocol { get }
	var parser: DataParserProtocol { get }

	func perform<T>(_ request: RequestProtocol) async throws -> T
	where T: Decodable
}

/// Network request manager.
public actor RequestManager: RequestManagerProtocol {

    // MARK: Stored properties
	public let apiManager: APIManagerProtocol
	public let parser: DataParserProtocol
    let tokenManager: AccessTokenManagerProtocol

	// MARK: - Init
	public init(
		apiManager: APIManagerProtocol = APIManager(),
		parser: DataParserProtocol = DataParser(),
		tokenManager: AccessTokenManagerProtocol = AccessTokenManager.shared
	) {
		self.apiManager = apiManager
		self.parser = parser
		self.tokenManager = tokenManager
	}

    /// Requests an access token, makes a network api call and decodes the received data.
    /// - Parameter request: URL request.
	///-   Throws: If the HTTP status is not success.
    /// - Returns: Result of request with decoded success or failure data.
	public func perform<T>(_ request: RequestProtocol) async throws -> T
	where T: Decodable {
        var token: String?

		if request.isNeedAccessToken {
			// If we don't have accessToken you throws for open LoginView
			token = try tokenManager.getToken()
		}
		let (data, response): (Data, HTTPURLResponse) = try await apiManager.perform(request, with: token)
// print(String(decoding: data, as: UTF8.self))
		switch response.statusCode {
		case 200..<300:
			if T.self == Int.self,		// HTTP Status
			   let status: T = response.statusCode as? T {
				return status
			} else {
				return try parser.decode(data: data)
			}
		case 401, 423:	// unauthorized, locked -> go to LoginView
			try? self.tokenManager.update(token: nil)
			throw NetworkError.goToLoginView
		default:
			let error: ErrorResponse = try parser.decode(data: data)
			throw error
		}
    }
}
