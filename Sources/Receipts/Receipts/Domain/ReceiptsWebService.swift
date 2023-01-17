//
//  ReceiptsWebService.swift
//  Receipts
//
//  Created by Roman Croitor on 14.07.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import DefaultAppConfiguration

public protocol ReceiptsWebService {
	func fetchReceiptStatements( limit: Int, cursor: String?) async throws -> ReceiptStatements
	
	func getReceiptDetailsRequest( receiptId: String) async throws -> URLRequest?
}
