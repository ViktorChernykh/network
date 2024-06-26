//
//  DataParser.swift
//  AdsUser
//
//  Created by Victor Chernykh on 12.11.2022.
//

import Foundation

/// Protocol for Data Parser.
public protocol DataParserProtocol {
    func decode<T: Decodable>(data: Data) throws -> T
}

/// Data decoder.
public struct DataParser: DataParserProtocol {
    // MARK: - Stored properties
    private let jsonDecoder: JSONDecoder

    // MARK: - Init
	public init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
        self.jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
		self.jsonDecoder.dateDecodingStrategy = .iso8601
    }

	public func decode<T: Decodable>(data: Data) throws -> T {
        try jsonDecoder.decode(T.self, from: data)
    }
}
