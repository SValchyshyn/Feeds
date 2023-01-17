//
//  FeedbackViewModel.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 11.01.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import CoopCore
import Tracking

protocol FeedbackViewModelDelegate: AnyObject {
	func updateSubviews()
	func configurePredefinedOptionsView(with options: [String])
}

public class FeedbackViewModel {
	
	enum Constants {
		static let feedbackAvailability: Double = 48 * 60 * 60 // 48 hours
	}

	enum ContentType: Equatable {
		case rating
		case ratingAndFreeText( Int16 )
		case generalThanks
		case hidden
	}
	private let feedbackRepository: CustomerFeedbackRepository
	private(set) var contentType: ContentType = .hidden
	private let receiptData: ReceiptData
	private var hasShownAnimation: Bool
	private var feedback: Feedback?
	public var animationCallback: (() -> Void)?
	weak var delegate: FeedbackViewModelDelegate?
	
	public init(receiptData: ReceiptData, feedback: Feedback?, repository: CustomerFeedbackRepository, hasShownAnimation: Bool) {
		self.receiptData = receiptData
		self.hasShownAnimation = hasShownAnimation
		self.feedback = feedback
		self.feedbackRepository = repository
		
		determineContenType()
	}
	
	var canPlayAnimation: Bool {
		feedbackRepository.isDataLoaded && contentType == .rating && !hasShownAnimation
	}
	
	var thankYouMessage: String {
		feedback?.thankYouMessage ?? CustomerFeedbackLocalizedString("customer_feedback_thank_you_message")
	}
	
	var stagedFeedback: String? {
		feedback?.stagedFeedback
	}
	
	var stagedOptions: [String] {
		feedback?.stagedOptions ?? []
	}
	
	func animationDidStartPlaying() {
		hasShownAnimation = true
		animationCallback?()
	}
	
	func stageFeedback(message: String) {
		feedback?.stagedFeedback = message
	}
	
	func stageOptions(options: [String]) {
		feedback?.stagedOptions = options
	}
	
	private func determineContenType() {
		if let feedback = self.feedback {
			// The feedback has been already closed, so can't edit it anymore
			if feedback.state == .closed {
				contentType = .generalThanks
			} else {
				// Feedback was not provided, display the feedback view
				contentType = .ratingAndFreeText(feedback.rating)
				// Get predefined options and attach it to the feedback
				getPredefinedOptions(for: receiptData.chainOptionsIdentifier, filteredBy: Int(feedback.rating))
			}
		} else if receiptData.publishDate.addingTimeInterval( Constants.feedbackAvailability ) > Date() {
			// No feedback created, display one if we are still in the 48 hours interval
			contentType = .rating
		} else {
			// There is no feedback and the 48 hours window passed, hide the feedback
			contentType = .hidden
		}
	}
	
	func updateFeedback(with rating: Int) {
		guard feedback?.rating != Int16(rating) else { return }
		// Need to reset staged options if rating is changed
		feedback?.stagedOptions = []
		
		let feedbackData = FeedbackData(receiptId: receiptData.receiptId,
									chainName: receiptData.chainName,
									chainId: receiptData.chainId,
									storeName: receiptData.storeName,
									storeId: receiptData.storeId,
									rating: rating)
		
		if feedback == nil {
			feedbackRepository.createFeedback(feedbackData: feedbackData) { result in
				self.handleUpdateFeedbackResponse(result: result)
				
				Tracking.shared.feedbackRatingInitiated(rating: rating,
													  receiptID: self.receiptData.receiptId)
			}
		} else {
			feedbackRepository.updateFeedback(feedback: feedbackData) { result in
				self.handleUpdateFeedbackResponse(result: result)
			}
		}
		
		getPredefinedOptions(for: receiptData.chainOptionsIdentifier, filteredBy: rating)
	}
	
	func completeFeedback(with message: String) {
		guard let rating = feedback?.rating else { return }
		
		let feedbackData = FeedbackData(receiptId: receiptData.receiptId,
								chainName: receiptData.chainName,
								chainId: receiptData.chainId,
								storeName: receiptData.storeName,
								storeId: receiptData.storeId,
								rating: Int(rating),
								state: .closed,
								options: stagedOptions,
								message: message)
		
		// Notify that feedback is done and get the response from the server
		feedbackRepository.updateFeedback(feedback: feedbackData) { [weak self] result in
			DispatchQueue.main.async {
				
				switch result {
				case.success( let updatedFeedback):
					self?.feedback = updatedFeedback
					
					// Animate down the general thanks
					self?.contentType = .generalThanks
					self?.delegate?.updateSubviews()
					
				case .failure:
					// Type doesn't change, so nothing to be done here
					break
				}
			}
		}
	}
	
	func deleteFeedback() {
		feedbackRepository.deleteFeedback(with: receiptData.receiptId) { [weak self] result in
			DispatchQueue.main.async {
				switch result {
				case.success:
					
					self?.feedback = nil
					self?.contentType = .rating
					self?.delegate?.updateSubviews()
					
				case .failure:
					// Type doesn't change, so nothing to be done here
					break
				}
			}
		}
	}
	
	private func getPredefinedOptions(for chainId: String, filteredBy rating: Int) {
		feedbackRepository.getOptions(for: chainId) { [weak self] predefinedOptions in
			let options = predefinedOptions.filter { $0.rating == rating }.map { $0.option }
			self?.delegate?.configurePredefinedOptionsView(with: options)
		}
	}
	
	private func handleUpdateFeedbackResponse(result: Result<Feedback, Error>) {
		DispatchQueue.main.async {
			switch result {
			case.success(let updatedFeedback):
				self.feedback = updatedFeedback
				self.contentType = .ratingAndFreeText(updatedFeedback.rating)
				self.delegate?.updateSubviews()

			case .failure:
				// Type doesn't change, so nothing to do here
				break
			}
		}
	}	
}
