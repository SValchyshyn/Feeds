//
//  CustomerFeedbackAPI.swift
//  CustomerFeedback
//
//  Created by Stepan Valchyshyn on 07.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import CoreDataManager

public protocol CustomerFeedbackAPI {
	func getFeedbacks(coreDataUpdater: CoreDataUpdater<Feedback>, completion: @escaping ( Result< FeedbackResponse, Error > ) -> Void)
	func createFeedback(feedbackData: FeedbackData, completion: @escaping (Result<FeedbackState, Error>) -> Void)
	func updateFeedback(feedbackData: FeedbackData, completion: @escaping (Result< FeedbackState, Error >) -> Void)
	func deleteFeedback(with receiptId: String, completion: @escaping (Result< Void, Error >) -> Void)
	func getPredefinedOptions(for chainId: String, completion: @escaping (Result<[PredefinedOption], Error >) -> Void)
}
