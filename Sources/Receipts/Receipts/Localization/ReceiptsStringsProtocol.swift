//
//  ReceiptsStringsProtocol.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 30.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation

public protocol ReceiptsStringsProtocol {
	var emptySectionTitle: String { get }
	var noReceiptsText: String { get }
	var receiptsListTitle: String { get }
	var receiptsCommingSoonAlertTitle: String { get }
	var receiptsCommingSoonAlertBody: String { get }
	var cannotGetReceiptsAlertTitle: String { get }
	var cannotGetReceiptsAlertBody: String { get }
}
