//
//  ReceiptData.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 08.12.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import Foundation

public struct ReceiptData {
	let receiptId: String
	let publishDate: Date
	let chainId: String?
	let storeId: String?
	// A non-nil property used for predefined options fetching. For CoopDK it's value is `chainName` while for whitelabel apps it is `chainId`.
	// This properties should be removed once we migrate CoopDK to platform StoreAPI
	let chainOptionsIdentifier: String
	let chainName: String?
	let storeName: String?
	
	public init(receiptId: String, publishDate: Date, chainId: String? = nil, chainName: String? = nil, storeId: String? = nil, storeName: String? = nil, chainOptionsIdentifier: String) {
		self.receiptId = receiptId
		self.publishDate = publishDate
		self.chainId = chainId
		self.chainName = chainName
		self.storeId = storeId
		self.storeName = storeName
		self.chainOptionsIdentifier = chainOptionsIdentifier
	}
}
