//
//  OptionView.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 15.12.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import UIKit
import CoreUserInterface

protocol OptionViewDelegate: AnyObject {
	func optionView(_ optionView: OptionView, didSelect option: String)
	func optionView(_ optionView: OptionView, didDeselect option: String)
}

class OptionView: UIView {
	
	weak var delegate: OptionViewDelegate?

	@IBOutlet var checkboxImageView: UIImageView!
	@IBOutlet var optionTitleLabel: UILabel! {
		didSet {
			optionTitleLabel.textColor = colorsContent.bodyTextColor
			optionTitleLabel.font = fontProvider[.regular(.body)]
		}
	}
	
	@IBAction private func tapAction(_ sender: Any) {
		checkboxImageView.isHighlighted.toggle()
		
		guard let option = optionTitleLabel.text else { return }
		checkboxImageView.isHighlighted
			? delegate?.optionView(self, didSelect: option)
			: delegate?.optionView(self, didDeselect: option)
	}
}
