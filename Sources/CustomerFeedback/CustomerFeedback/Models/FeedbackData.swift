//
//  FeedbackData.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 08.12.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import Foundation

public struct FeedbackData: Codable {
	
	enum State: String, Codable {
		case open = "Open"
		case closed = "Closed"
	}
	
	let receiptId: String
	let chainName: String?
	let chainId: String?
	let storeName: String?
	let storeId: String?
	let rating: Int
	let options: [String]
	let message: String
	let state: State
	
	init(receiptId: String,
		 chainName: String? = nil,
		 chainId: String? = nil,
		 storeName: String? = nil,
		 storeId: String? = nil,
		 rating: Int,
		 state: State = .open,
		 options: [String] = [],
		 message: String = "") {
		self.receiptId = receiptId
		self.chainName = chainName
		self.storeName = storeName
		self.rating = rating
		self.state = state
		self.options = options
		self.message = message
		self.chainId = chainId
		self.storeId = storeId
	}
}
