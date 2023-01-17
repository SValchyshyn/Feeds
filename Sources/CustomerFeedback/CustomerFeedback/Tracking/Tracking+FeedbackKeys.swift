//
//  Tracking+FeedbackKeys.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 18.06.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import CoopCore
import Tracking

public extension Tracking {
	enum FeedbackKeys {
		public static let receiptID = "receipt_id"
		public static let feedbackRating = "feedback_rating"
	}
	
	enum FeedbackEvents {
		public static let ratingIntitiated = "feedback_rating_initiated"
	}
}
