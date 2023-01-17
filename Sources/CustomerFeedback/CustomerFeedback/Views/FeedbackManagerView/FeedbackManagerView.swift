//
//  FeedbackManagerView.swift
//  CustomerFeedback
//
//  Created by Roxana-Madalina Sturzu on 09/09/2020.
//  Copyright © 2020 LOBYCO. All rights reserved.
//

import UIKit
import CoreUserInterface

public class FeedbackManagerView: UIView {
	
	// MARK: - IBOutlets
	@IBOutlet var containerView: UIView!
	@IBOutlet var smilesView: SmilesRatingView!
	@IBOutlet var predefinedOptionsView: PredefinedOptionsView!
	@IBOutlet var freeTextView: FreeTextFeedbackView!
	@IBOutlet var generalThanksView: ThankYouView!

	// MARK: - Properties
	private weak var delegate: CustomerFeedbackManagerDelegate?
	private var viewModel: FeedbackViewModel? {
		didSet { viewModel?.delegate = self }
	}

	public required init?( coder aDecoder: NSCoder ) {
		super.init( coder: aDecoder )
		commonInit()
	}

	public func prepareForReuse() {
		delegate = nil
		viewModel = nil
		isHidden = false
		smilesView.cancelAnimation()
	}
	
	public func viewWillBeShown() {
		guard viewModel?.canPlayAnimation == true else { return }
		smilesView.playAnimation()
		viewModel?.animationDidStartPlaying()
	}
	
	/**
	Configures the manager with the required receipt and feedback data, displaying the proper state.
	- parameter viewModel: 		A set of data about receipt, such as: receiptId, publishDate, chainName and storeName.
	- parameter delegate:		`CustomerFeedbackManagerDelegate` that will be notified when rating and feeback are completed.
	*/
	public func configure(with viewModel: FeedbackViewModel, delegate: CustomerFeedbackManagerDelegate) {
		self.delegate = delegate
		self.viewModel = viewModel
		generalThanksView.delegate = delegate
		displayCurrentContent()
	}

	/// Ties the class to the `.xib`.
	private func commonInit() {
		Bundle( for: Self.self ).loadNibNamed( "FeedbackManagerView", owner: self, options: nil )
		containerView.translatesAutoresizingMaskIntoConstraints = false
		containerView.frame = bounds
		addSubview( containerView )
		containerView.pinEdges( to: self )

		freeTextView.delegate = self
		smilesView.delegate = self
		predefinedOptionsView.delegate = self
		
		// Setup accessibility ids for UITests
		smilesView.accessibilityLabel = "smilesView"
		predefinedOptionsView.accessibilityLabel = "predefinedOptionsView"
		freeTextView.accessibilityLabel = "freeTextView"
		generalThanksView.accessibilityLabel = "generalThanksView"
	}
	
	/// Hides all subviews
	private func hideAllSubViews() {
		freeTextView.isHiddenInStackView = true
		smilesView.isHiddenInStackView = true
		predefinedOptionsView.isHiddenInStackView = true
		generalThanksView.isHiddenInStackView = true
	}

	/// Shows the arranged subview based on the type
	private func displayCurrentContent() {
		guard let viewModel = viewModel else { return }
		
		// Start by hiding all views then show only the relevant ones
		hideAllSubViews()

		switch viewModel.contentType {
		case .rating:
			smilesView.resetRating()
			smilesView.isHiddenInStackView = false

		case .ratingAndFreeText(let rating):
			smilesView.isHiddenInStackView = false
			smilesView.setRating(Int(rating))
			predefinedOptionsView.isHiddenInStackView = false
			predefinedOptionsView.select(options: viewModel.stagedOptions)
			freeTextView.isHiddenInStackView = false
			freeTextView.feedbackText = viewModel.stagedFeedback

		case .generalThanks:
			generalThanksView.messageLabel.text = viewModel.thankYouMessage
			generalThanksView.isHiddenInStackView = false

		case .hidden:
			self.isHidden = true
		}
	}
}

extension FeedbackManagerView: CustomerFeedbackContentDelegate {

	public func ratingDone(rating: Int) {
		viewModel?.updateFeedback(with: rating)
	}
	
	public func optionsDidChange(options: [String]) {
		viewModel?.stageOptions(options: options)
	}

	public func commentDone(message: String) {
		viewModel?.completeFeedback(with: message)
	}
	
	public func commentDidChange(message: String) {
		viewModel?.stageFeedback(message: message)
	}
	
	public func feedbackCancelled() {
		viewModel?.deleteFeedback()
	}
}

extension FeedbackManagerView: FeedbackViewModelDelegate {
	
	func configurePredefinedOptionsView(with options: [String]) {
		DispatchQueue.main.async {
			self.predefinedOptionsView.configure(with: options)
			// Check if type is correspoding to show predefined options
			guard let viewModel = self.viewModel, case .ratingAndFreeText = viewModel.contentType else { return }
			self.predefinedOptionsView.isHiddenInStackView = false
			self.predefinedOptionsView.select(options: viewModel.stagedOptions)
			
			// Animate changes
			self.delegate?.contentChanged()
			self.layoutIfNeeded()
		}
	}
	
	func updateSubviews() {
		UIView.animate(withDuration: Theme.Durations.standardAnimationDuration, animations: {
			self.displayCurrentContent()
			self.layoutIfNeeded()
			self.delegate?.contentChanged()
		}, completion: { success in
			if success {
				self.delegate?.reloadTable()
			}
		})
	}
}

fileprivate extension UIView {

	// NOTE: https://stackoverflow.com/questions/40001416/swift-disappearing-views-from-a-stackview
	// The bug is that hiding and showing views in a stack view is cumulative.
	// If you hide view in stack view twice, you need to show it twice to get it back.
	var isHiddenInStackView: Bool {
		get { isHidden }
		set { if isHidden != newValue { isHidden = newValue } }
	}
}
