//
//  Models.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import CoopCore

public struct ReceiptStatements: Decodable {
	public let receipts: [ReceiptItem]
	public let nextCursor: String?
}

public struct ReceiptItem: Decodable {
	enum CodingKeys: String, CodingKey {
		case id = "receiptId"
		case storeName
		case totalAmount
		case purchaseTimestamp = "localPurchaseTimestamp"
	}
	
	public let id: String
	public let storeName: String
	public let purchaseTimestamp: String
	public let totalAmount: Amount
}
