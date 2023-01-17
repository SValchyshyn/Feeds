//
//  FreeTextFeedbackView.swift
//  CoopM16
//
//  Created by Roxana-Madalina Sturzu on 13/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//

import UIKit
import CoreUserInterface

public class FreeTextFeedbackView: CustomerFeedbackView {
	
	enum Constants {
		static let maxAllowedCharacters = 500
	}
	
	@IBOutlet private var contentView: UIView!
	@IBOutlet private weak var textView: PlaceholderTextView!
	@IBOutlet private weak var sendButton: UIButton! {
		didSet {
			sendButton.backgroundColor = colorsContent.primaryColor
			sendButton.setTitleColor(colorsContent.colorSurface, for: .normal)
			sendButton.titleLabel?.font = fontProvider[.medium(.body)]
			sendButton.layer.borderColor = colorsContent.primaryColor.cgColor
			sendButton.layer.borderWidth = 1
			sendButton.layer.cornerRadius = 4
		}
	}
	@IBOutlet private weak var cancelButton: UIButton! {
		didSet {
			cancelButton.titleLabel?.font = fontProvider[.medium(.body)]
			cancelButton.setTitleColor( colorsContent.primaryColor, for: .normal )
			cancelButton.layer.borderColor = colorsContent.primaryColor.cgColor
			cancelButton.layer.borderWidth = 1
			cancelButton.layer.cornerRadius = 4
		}
	}
	
	var feedbackText: String? {
		get { textView.text }
		set { textView.text = newValue }
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
		Bundle( for: Self.self ).loadNibNamed( "FreeTextFeedbackView", owner: self, options: nil )
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.frame = bounds
		addSubview( contentView )
		contentView.pinEdges( to: self )

		sendButton.setTitle( CustomerFeedbackLocalizedString("customer_feedback_send_button"), for: .normal)
		cancelButton.setTitle(CustomerFeedbackLocalizedString("customer_feedback_cancel_button"), for: .normal)

		// Setup textView and it's border
		textView.delegate = self
		textView.layer.borderWidth = 1
		textView.layer.borderColor = Theme.Colors.gray.cgColor
		textView.layer.cornerRadius = 5
		textView.textColor = Theme.Colors.darkGray

		// Setup the placeholder text
		textView.placeholderColor = Theme.Colors.gray
		textView.placeholder = CustomerFeedbackLocalizedString("customer_feedback_input_hint")
	}

	@IBAction private func sendCommentAction(_ sender: Any) {
		textView.resignFirstResponder()
		delegate?.commentDone( message: textView.text )
	}

	@IBAction private func cancelAction(_ sender: Any) {
		textView.resignFirstResponder()
		delegate?.feedbackCancelled()
	}
	
}

extension FreeTextFeedbackView: UITextViewDelegate {
	
	public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		// Make sure the message is at most 500 characters long
		
		// Get the current text, or use an empty string if that failed
		let currentText = textView.text ?? ""
		
		// Attempt to read the range they are trying to change, or exit if we can't
		guard let stringRange = Range(range, in: currentText) else { return false }
		
		// Add their new text to the existing text
		let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
		
		// Make sure the result is under 500 characters
		return updatedText.count <= Constants.maxAllowedCharacters
	}
	
	public func textViewDidChange(_ textView: UITextView) {
		delegate?.commentDidChange( message: textView.text )
	}
}
