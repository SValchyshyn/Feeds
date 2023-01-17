//
//  Mappers.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import CoopCore

extension ReceiptStatements {
	func mapToDomain() -> ReceiptStatementsDomain {
		ReceiptStatementsDomain( statements: receipts.compactMap { $0.mapToDomain() }, nextCursor: nextCursor )
	}
}

fileprivate extension ReceiptItem {
	func mapToDomain() -> ReceiptItemDomain? {
		// There is a bug on back-end that we receive dates in wrong time zone,
		// We have a requirement to display/process time for receipts without time zone (as UTC time zone)
		// So we convert purchased date from current to UTC time zone to fix this issue
		guard let fixedPurchaseDate = purchaseDate?.convert(from: .fittedTimeZone, to: .utc) else { return nil }
		return ReceiptItemDomain( id: id, storeName: storeName, amount: totalAmount, purchaseTimestamp: fixedPurchaseDate )
	}
	
	/// Converts `purchaseTimestamp` into `Date`
	private var purchaseDate: Date? {
		// We can receive `purchaseTimestamp` with milliseconds or without
		DateFormatter.iso8601FormatterWithMilliseconds.date(from: purchaseTimestamp)
			?? DateFormatter.utcFormatterWithoutMilliseconds.date(from: purchaseTimestamp)
	}
}

fileprivate extension Date {
	func convert(from initTimeZone: TimeZone, to targetTimeZone: TimeZone) -> Date {
		let delta = TimeInterval(targetTimeZone.secondsFromGMT(for: self) - initTimeZone.secondsFromGMT(for: self))
		return addingTimeInterval(delta)
	}
}
