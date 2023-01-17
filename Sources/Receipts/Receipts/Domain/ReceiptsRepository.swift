//
//  ReceiptsRepository.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

public protocol ReceiptsRepository {
	/**
	Fetches the `ReceiptStatements` in a paginated fashion.
	
	- parameter limit:				How much items to request.
	- parameter cursor:				Id of the last received bonus statement. Nil if it is the beginning of the list.
	- parameter completion:			Called from the `DispatchQueue.main` after the response is received.
	*/
	func getReceiptStatements( limit: Int, cursor: String?) async throws -> ReceiptStatementsDomain
	
	/**
	Get preconfigured `URLRequest` to open particular receipt web details page.
	
	- parameter receiptId:			Id of the receipt that request should be generated for.
	*/
	func getReceiptDetailsRequest( receiptId: String) async throws -> URLRequest
}
