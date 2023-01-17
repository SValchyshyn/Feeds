//
//  Tracking+Events.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 18.06.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import CoopCore
import Tracking

extension Tracking {
	
	func feedbackRatingInitiated(rating: Int, receiptID: String) {
		let parameters = [
			Tracking.FeedbackKeys.feedbackRating: rating.description,
			Tracking.FeedbackKeys.receiptID: receiptID ]
		let event = Tracking.FeedbackEvents.ratingIntitiated
		trackEvent(event: event, parameters: parameters, includeExtraInfo: true)
	}
}
