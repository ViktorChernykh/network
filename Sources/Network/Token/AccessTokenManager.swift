//
//  AccessTokenManager.swift
//  AdsUser
//
//  Created by Victor Chernykh on 12.11.2022.
//

import Foundation
import KeyChaining

/// Protocol for work with AccessTokenManager.
public protocol AccessTokenManagerProtocol: AnyObject {
	var isHasToken: Bool { get }
	func getLogin() throws -> String
	func getToken() throws -> String
	func getUserId() throws -> UUID
	func update(login: String?) throws
	func update(token: String?) throws
	func update(userId: UUID?) throws
}

/// Manager for work with AccessTokenManager.
final public class AccessTokenManager {
	public static var shared: AccessTokenManager {
		guard let instance else {
			fatalError("AccessTokenManager has not been initialized. Call shared(...:) first.")
		}
		return instance
	}
	private static var instance: AccessTokenManager?

	static func makeInstance(
		keyChainManager: KeychainProtocol? = nil,
		userServiceScheme: String,
		userServiceHost: String,
		keyLogin: String,
		keyAccess: String,
		keyUserId: String
	) {
		if Self.instance == nil {
			Self.instance = AccessTokenManager(
				keyChainManager: keyChainManager,
				userServiceScheme: userServiceScheme,
				userServiceHost: userServiceHost,
				keyLogin: keyLogin,
				keyAccess: keyAccess,
				keyUserId: keyUserId
			)
		}
	}

	// Thread safe queue
	private let threadSafeQueue = DispatchQueue(label: "ThreadSafeQueue", attributes: .concurrent)
	private let keyChainManager: KeychainProtocol
	private let userServiceScheme: String
	private let userServiceHost: String
	private let keyLogin: String
	private let keyAccess: String
	private let keyUserId: String

	private var token: String?
	private var userId: UUID?

	private var _login: String?
	private var login: String? {
		get {
			threadSafeQueue.sync {
				_login
			}
		} set {
			threadSafeQueue.async(flags: .barrier) { [unowned self] in
				self._login = newValue
			}
		}
	}

	private var _isLogin: Bool?
	private var isLogin: Bool? {
		get {
			threadSafeQueue.sync {
				_isLogin
			}
		} set {
			threadSafeQueue.async(flags: .barrier) { [unowned self] in
				self._isLogin = newValue
			}
		}
	}

	// MARK: - Init
	private init(
		keyChainManager: KeychainProtocol? = nil,
		userServiceScheme: String,
		userServiceHost: String,
		keyLogin: String,
		keyAccess: String,
		keyUserId: String
	) {
		self.userServiceScheme = userServiceScheme
		self.userServiceHost = userServiceHost
		self.keyLogin = keyLogin
		self.keyAccess = keyAccess
		self.keyUserId = keyUserId

		if let keyChainManager {
			self.keyChainManager = keyChainManager
			return
		}

		let password = InternetPassword(
			server: userServiceHost,
			internetProtocol: InternetProtocol(rawValue: userServiceScheme)
		)
		self.keyChainManager = KeychainInterface(passwordQuery: password)
		token = try? getToken()
	}
}

// MARK: - AccessTokenManagerProtocol
extension AccessTokenManager: AccessTokenManagerProtocol {
	public var isHasToken: Bool {
		token != nil
	}

	/// Get login from Keychain or from cache.
	/// - Returns: The user's login
	public func getLogin() throws -> String {
		if let login {
			// Return cached login if available
			return login
		}
		// Fetch login from Keychain
		self.login = try keyChainManager.getValue(for: keyLogin)
		guard let login: String = self.login else {
			throw AccessTokenManagerError.noLogin
		}
		return login
	}

	/// Get the user's access token from Keychain or cache.
	/// - Returns: The user's access token
	public func getToken() throws -> String {
		// Return cached token if available
		if let token {
			return token
		}

		// Fetch token components from Keychain
		guard let access: String = try keyChainManager.getValue(for: keyAccess) else {
			throw NetworkError.goToLoginView
		}
		self.token = access

		return access
	}

	/// Get the user's unique identifier (UUID) from Keychain or cache.
	/// - Returns: The user's UUID
	public func getUserId() throws -> UUID {
		if let userId {
			// Return cached user ID if available
			return userId
		}

		// Fetch user ID from Keychain
		guard let stringId: String = try keyChainManager.getValue(for: keyUserId),
			  let uuid: UUID = .init(uuidString: stringId) else {
			throw KeyChainError.noUserId
		}
		self.userId = uuid

		return uuid
	}

	public func update(login: String?) throws {
		// Update and cache the user's login
		self.login = login

		// Save the login to Keychain if it exists, otherwise remove it
		if let login {
			try keyChainManager.setValue(login, for: keyLogin)
		} else {
			_ = try keyChainManager.removeValue(for: keyLogin)
		}
	}

	/// Update the user's access token and store it in Keychain, or remove it if `nil`.
	/// - Parameter token: The new user's access token to be stored
	/// - Throws: An error if the token cannot be updated or stored
	public func update(token: String?) throws {
		// Update and cache the access token
		self.token = token

		// Save the token components to Keychain if it exists, otherwise remove them
		if let token {
			try keyChainManager
				.setValue(token, for: keyAccess)
		} else {
			_ = try keyChainManager.removeAllValues()
		}
	}

	/// Update the user's unique identifier (UUID) and store it in Keychain, or remove it if `nil`.
	/// - Parameter userId: The new user's UUID to be stored.
	/// - Throws: An error if the user ID cannot be updated or stored.
	public func update(userId: UUID?) throws {
		// Update and cache the user ID
		self.userId = userId

		// Save the user ID to Keychain if it exists, otherwise remove it
		if let userId {
			try keyChainManager.setValue(userId.uuidString, for: keyUserId)
		} else {
			_ = try keyChainManager.removeValue(for: keyUserId)
		}
	}
}
