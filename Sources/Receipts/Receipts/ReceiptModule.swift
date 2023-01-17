//
//  ReceiptModule.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Core
import CoreUserInterface

public final class ReceiptModule {
	// MARK: - Singleton
	public static let shared = ReceiptModule()
	private init() {}
	
	// MARK: - Injectables
	@Injectable fileprivate var commonStringsContent: CommonStringsProtocol
	@Injectable fileprivate var receiptsStringsContent: ReceiptsStringsProtocol
	@Injectable fileprivate var fontProvider: PlatformFontProvider
	@Injectable fileprivate var colorsProtocol: ColorsProtocol
}

let commonContent = ReceiptModule.shared.commonStringsContent
let stringsContent = ReceiptModule.shared.receiptsStringsContent
let fontProvider = ReceiptModule.shared.fontProvider
let colorsContent = ReceiptModule.shared.colorsProtocol
