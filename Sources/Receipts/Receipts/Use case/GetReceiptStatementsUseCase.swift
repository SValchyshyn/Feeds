//
//  GetReceiptStatementsUseCase.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

/// Use case class that incapsulates pagination logic inside. `getNextPage` is all you need to load more statement items.
public final class GetReceiptStatementsUseCase {
	private enum Constants {
		// Pagination limit
		static let limit = 50
	}
	
	private var receiptRepository: ReceiptsRepository
	private var nextCursor: String?
	public private(set) var isFullyLoaded = false
	
	public init( receiptRepository: ReceiptsRepository ) {
		self.receiptRepository = receiptRepository
	}
	
	public func getNextPage() async throws -> [ReceiptItemDomain] {
		guard !isFullyLoaded else {
			// The end of the list. Return empty list
			let receiptItems: [ReceiptItemDomain] = []
			return receiptItems
		}
		
		let response: ReceiptStatementsDomain = try await receiptRepository.getReceiptStatements(limit: Constants.limit, cursor: nextCursor)
		nextCursor = response.nextCursor
		isFullyLoaded = response.nextCursor == nil
		
		return response.statements
	}
}
