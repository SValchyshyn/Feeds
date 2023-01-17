//
//  ReceiptModels.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoopCore

public struct ReceiptStatementsDomain {
	public let statements: [ReceiptItemDomain]
	public let nextCursor: String?
	
	public init( statements: [ReceiptItemDomain], nextCursor: String? ) {
		self.statements = statements
		self.nextCursor = nextCursor
	}
}

public struct ReceiptItemDomain {
	public let id: String
	public let storeName: String
	public let amount: Amount
	public let purchaseTimestamp: Date
	
	public init( id: String,
				 storeName: String,
				 amount: Amount,
				 purchaseTimestamp: Date ) {
		self.id = id
		self.storeName = storeName
		self.amount = amount
		self.purchaseTimestamp = purchaseTimestamp
	}
}

extension ReceiptItemDomain: DateGroupable {
	public var groupByDate: Date {
		return purchaseTimestamp
	}
}
