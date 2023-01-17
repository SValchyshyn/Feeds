//
//  SmilesRatingView.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 07.10.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import UIKit
import CoreUserInterface

protocol RatingView: AnyObject {
	func setRating(_ rating: Int)
	func resetRating()
}

public class CustomerFeedbackView: UIView {
	public weak var delegate: CustomerFeedbackContentDelegate?
}

class SmilesRatingView: CustomerFeedbackView, RatingView {
	
	@IBOutlet private var contentView: UIView!
	@IBOutlet private var titleLabel: UILabel! {
		didSet {
			titleLabel.textColor = colorsContent.bodyTextColor
			titleLabel.font = fontProvider[.regular(.body)]
			titleLabel.text = CustomerFeedbackLocalizedString("customer_feedback_rating_title")
		}
	}
	
	@IBOutlet private var smiles: [UIButton]!
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	private func commonInit() {
		Bundle(for: Self.self ).loadNibNamed(String(describing: Self.self), owner: self)
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.frame = bounds
		addSubview(contentView)
		contentView.pinEdges(to: self)
		becomeFirstResponder()
	}
	
	func configure( delegate: CustomerFeedbackContentDelegate ) {
		self.delegate = delegate
	}
	
	func setRating(_ rating: Int) {
		resetRating()
		smiles.first(where: { $0.tag == rating })?.isSelected = true
	}
	
	func resetRating() {
		smiles.forEach { $0.isSelected = false }
	}

	// MARK: - IBAction
	
	@IBAction func smileyPressed(_ button: UIButton) {
		cancelAnimation()
		setRating(button.tag)
		delegate?.ratingDone(rating: button.tag)
	}
	
	// MARK: - Smiles animation
	
	private var smileysAnimator: SmileysAnimator?
	
	func playAnimation() {
		smileysAnimator = SmileysAnimator(smiles: smiles)
		smileysAnimator?.start()
	}
	
	func cancelAnimation() {
		smileysAnimator?.cancel()
	}
}
