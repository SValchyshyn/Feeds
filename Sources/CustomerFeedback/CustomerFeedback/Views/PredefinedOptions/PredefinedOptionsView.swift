//
//  PredefinedOptionsView.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 15.12.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import CoreUserInterface
import UIKit

class PredefinedOptionsView: CustomerFeedbackView, OptionViewDelegate {

	@IBOutlet private var contentView: UIView!
	@IBOutlet private var stackView: UIStackView!
	@IBOutlet private var titleLabel: UILabel! {
		didSet {
			titleLabel.textColor = colorsContent.bodyTextColor
			titleLabel.font = fontProvider[.regular(.body)]
			titleLabel.text = CustomerFeedbackLocalizedString("customer_feedback_options_title")
		}
	}
	
	private var availableOptions: [String] = []
	private var selectedOptions: [String] = [] {
		didSet { delegate?.optionsDidChange(options: selectedOptions) }
	}
	
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
	}
	
	func configure(with options: [String]) {
		availableOptions = options
		stackView.removeAllArrangedSubviews2()
		
		for option in options {
			let optionView = OptionView.loadFromNib()
			optionView.optionTitleLabel.text = option
			optionView.delegate = self
			stackView.addArrangedSubview(optionView)
		}
	}
	
	func select(options: [String]) {
		selectedOptions = options
		
		for (index, optionView) in stackView.arrangedSubviews.enumerated() {
			guard let optionView = optionView as? OptionView else { continue }
			optionView.checkboxImageView.isHighlighted = selectedOptions.contains(availableOptions[index])
		}
	}
	
	func optionView(_ optionView: OptionView, didSelect option: String) {
		guard !selectedOptions.contains(option) else { return }
		selectedOptions.append(option)
	}
	
	func optionView(_ optionView: OptionView, didDeselect option: String) {
		selectedOptions.removeAll { $0 == option }
	}
	
}
