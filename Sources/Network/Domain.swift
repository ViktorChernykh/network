//
//  Domain.swift
//  AdsUser
//
//  Created by Victor Chernykh on 15.11.2022.
//

/// Server address.
public struct Domain: CustomStringConvertible {
    // MARK: - Stored properties
	public let scheme: String
	public let host: String
	public let port: Int?

	public var description: String {
		var site: String = "\(scheme)//:\(host)"
		if let port {
			site += ":\(port)"
		}
		return site
	}

    // MARK: - Init
	public init(scheme: String, host: String, port: Int?) {
        self.scheme = scheme
        self.host = host
        self.port = port
    }
}
