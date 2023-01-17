//
//  CustomerFeedbackModule.swift
//  CustomerFeedback
//
//  Created by Stepan Valchyshyn on 20.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Core
import CoreUserInterface

final class CustomerFeedbackModule {
	// MARK: - Singleton
	public static let shared = CustomerFeedbackModule()
	private init() {}
	
	// MARK: - Injectables
	@Injectable fileprivate var fontProvider: PlatformFontProvider
	@Injectable fileprivate var colorsContent: ColorsProtocol
}

let fontProvider = CustomerFeedbackModule.shared.fontProvider
let colorsContent = CustomerFeedbackModule.shared.colorsContent
