//
//  AccessTokenManagerError.swift
//  AdsUser
//
//  Created by Victor Chernykh on 30.08.2023.
//

/// AccessTokenManager's errors.
enum AccessTokenManagerError: Error {
	case noLogin
	case noToken

	public var errorDescription: String {
		switch self {
		case .noLogin:
			return "There is no login in keychain."
		case .noToken:
			return "There is no token in keychain."
		}
	}
}
