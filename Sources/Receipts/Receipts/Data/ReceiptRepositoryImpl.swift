//
//  ReceiptRepositoryImpl.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import CoopCore
import Core

public final class ReceiptRepositoryImpl: ReceiptsRepository, Repository {
	private let receiptsWebService = ReceiptsWebServiceImpl()
	
	public init() {
		registerRepository()
	}
	
	public func getReceiptStatements(limit: Int, cursor: String?) async throws -> ReceiptStatementsDomain {
		let receiptStatements: ReceiptStatements = try await receiptsWebService.fetchReceiptStatements(limit: limit, cursor: cursor)
		let receiptStatementsDomain = receiptStatements.mapToDomain()
		
		return receiptStatementsDomain
	}
	
	public func getReceiptDetailsRequest( receiptId: String) async throws -> URLRequest {
		guard let request: URLRequest = try await receiptsWebService.getReceiptDetailsRequest(receiptId: receiptId) else {
			throw APIError.missingRequestInfo
		}
		return request
	}
	
	public func clearAllData() {
		// Nothing here for now
	}
}
