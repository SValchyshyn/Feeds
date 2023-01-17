//
//  FeedbackResponse.swift
//  CustomerFeedback
//
//  Created by Roxana-Madalina Sturzu on 31/07/2020.
//  Copyright © 2020 LOBYCO. All rights reserved.
//

import Foundation
import CoreDataManager

public struct FeedbackResponse: Decodable {
	
	enum CodingKeys: String, CodingKey {
		case title
		case detail
		case feedbacks = "feedbackItems"
	}
	
	public let feedbacks: [SafeCoreDataDecodable<Feedback>]?

	// In case of failure
	public let title: String?
	public let detail: String?
}

public struct FeedbackState: Decodable {
	let id: Int
	let thankYouMessage: String?
}
