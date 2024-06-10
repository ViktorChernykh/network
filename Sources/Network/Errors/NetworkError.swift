//
//  NetworkError.swift
//  Network
//
//  Created by Victor Chernykh on 14.08.2022.
//

/// Network Errors
public enum NetworkError: Error {
	case invalidServerResponse
	case invalidURL
	case goToLoginView

	case status(String)
	case noData
	case noResponse

	public var errorDescription: String? {
		switch self {
		case .invalidServerResponse:
			return "The server returned an invalid response."
		case .invalidURL:
			return "URL string is malformed."
		case .goToLoginView:
			return "Go to login view."

		case .status(let string):
			return string
		case .noData:
			return "Has no image"
		case .noResponse:
			return "No response"
		}
	}
}
