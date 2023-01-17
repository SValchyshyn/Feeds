//
//  ThankYouView.swift
//  CustomerFeedback
//
//  Created by Roxana-Madalina Sturzu on 02/08/2020.
//  Copyright © 2020 LOBYCO. All rights reserved.
//

import UIKit
import CoreUserInterface
import CoopCore

public protocol ThankYouViewDelegate: AnyObject {
	func handleURLClick(for url: URL)
}

class ThankYouView: UIView {
	@IBOutlet private var contentView: UIView!
	@IBOutlet weak var messageLabel: ClickableLinkLabel! {
		didSet {
			messageLabel.textColor = colorsContent.bodyTextColor
			messageLabel.font = fontProvider[.regular(.body)]
		}
	}
	
	@IBOutlet private weak var labelLeadingConstraint: NSLayoutConstraint!
	@IBOutlet private weak var labelTrailingConstraint: NSLayoutConstraint!
	public weak var delegate: ThankYouViewDelegate?

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	public func configure() {
		messageLabel.linkDelegate = self
		messageLabel.linkTextAttributes = [ .foregroundColor: colorsContent.primaryColor,
											.underlineStyle: NSUnderlineStyle.single.rawValue]
		// Limiting label width to help autolayout correctly compute label height
		let insets = labelLeadingConstraint.constant + labelTrailingConstraint.constant
		messageLabel.preferredMaxLayoutWidth = bounds.width - insets
	}

	/// Ties the class to the `.xib`.
	private func commonInit() {
		Bundle( for: Self.self ).loadNibNamed( "ThankYouView", owner: self, options: nil )
		contentView.translatesAutoresizingMaskIntoConstraints = false
		contentView.frame = bounds
		addSubview( contentView )
		contentView.pinEdges( to: self )
		configure()
	}
}

extension ThankYouView: ClickableLinkLabelDelegate {
	func clickedLinkWithURL(_ url: URL) {
		delegate?.handleURLClick(for: url)
	}
}
