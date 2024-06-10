//
//  KeyChainError.swift
//  AdsUser
//
//  Created by Victor Chernykh on 27.06.2023.
//

enum KeyChainError: Error {
	case noUserId
}

extension KeyChainError {
	var reason: String {
		switch self {
		case .noUserId:
			return "No user ID."
		}
	}
}
