//
//  PredefinedOption.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 08.12.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import Foundation

public struct PredefinedOptionsResponse: Decodable {
	public let options: [PredefinedOption]
}

public struct PredefinedOption: Decodable {
	let option: String
	let rating: Int
}
