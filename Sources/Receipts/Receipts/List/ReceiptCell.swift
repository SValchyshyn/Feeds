//
//  ReceiptCell.swift
//  CoopM16
//
//  Created by Nis Wegmann on 10/08/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import CoreUserInterface

class ReceiptCell: AdjustHighlightCell {
	@IBOutlet weak var purchaseDateLabel: UILabel!
	@IBOutlet weak var amountView: AmountView!
	@IBOutlet weak var storeNameLabel: UILabel!
	@IBOutlet weak var dividerView: UIView!

	public override func awakeFromNib() {
		super.awakeFromNib()
		setupView()
	}
	
	public func configure( with receipt: ReceiptItemDomain ) {
		self.purchaseDateLabel.text = DateFormatter.timeStampDateFormatter.string( from: receipt.purchaseTimestamp )
		self.amountView.amount = receipt.amount.value
		self.storeNameLabel.text = receipt.storeName
	}
	
	private func setupView() {
		contentView.backgroundColor = colorsContent.colorSurface
		storeNameLabel.font = fontProvider.linkFont
		storeNameLabel.textColor = colorsContent.bodyTextColor
		purchaseDateLabel.font = fontProvider[.regular(.caption)]
		purchaseDateLabel.textColor = colorsContent.labelTextColor
		amountView.configuration = AmountView.Configuration(isSymbolHidden: true, customDecimalType: .normal, customFontType: .custom(fontProvider[.bold(.body)]))
		amountView.textColor = colorsContent.bodyTextColor
		dividerView.backgroundColor = colorsContent.dividerColor
	}
}
