//
//  ReceiptsWebServiceImpl.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import AuthenticationDomain
import AuthenticationData
import Core
import DefaultAppConfiguration

final class ReceiptsWebServiceImpl: ReceiptsWebService {
	private enum Constants {
		// Query keys
		static let limitSizeQueryKey: String = "limit"
		static let cursorQueryKey: String = "cursor"
	}
	
	@Injectable private var authenticationManager: AuthenticationManager
	
	public func fetchReceiptStatements( limit: Int, cursor: String?) async throws -> ReceiptStatements {
		var query: [String: String] = [
			Constants.limitSizeQueryKey: "\(limit)"
		]
		
		if let cursor = cursor {
			query[Constants.cursorQueryKey] = cursor
		}
		
		let endpoint: ReceiptsEndpoint = .list
		
		let request: URLRequest = try .init( for: endpoint, httpMethod: .GET, query: query )
		guard let response: ReceiptStatements = try await URLSession.core.execute(request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier) else {
			throw APIError.invalidResponse
		}
		
		return response
	}
	
	public func getReceiptDetailsRequest( receiptId: String) async throws -> URLRequest? {
		let endpoint: ReceiptsEndpoint = .details( receiptId: receiptId )
		
		var request: URLRequest = try .init( for: endpoint, httpMethod: .GET )
		
		guard let bearerToken: String = try await getBearerToken(for: endpoint) else {
			throw APIError.tokenExpired
		}
		request.setValue( "Bearer \(bearerToken)", forHTTPHeaderField: "Authorization" )
		
		return request
	}
	
	private func getBearerToken( for endpoint: RemoteConfigurableAPIEndpoint) async throws -> String? {
		let bearerToken: String = try await authenticationManager.accessToken(for: endpoint.tokenRequest)
		return bearerToken
	}
}
