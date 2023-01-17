//
//  PurchaseFeedItemCell.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 05.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import CoreUserInterface
import Log

public protocol PurchaseFeedItemDelegate: AnyObject {
	func showReceiptDetails(receiptId: String)
}

open class PurchaseFeedItemCell: FeedItemCell {
	// MARK: IBOutlets
	@IBOutlet private weak var storeLogoImageView: AsyncImageView!
	@IBOutlet private weak var storeNameLabel: UILabel!
	@IBOutlet private weak var receiptBackgroundImageView: UIImageView!
	@IBOutlet public private(set) weak var receiptContainerView: UIView!
	@IBOutlet public weak var receiptStackView: UIStackView!

	private weak var delegate: PurchaseFeedItemDelegate?
	
	open override func reset() {
		super.reset()
		storeLogoImageView.cancelLoading()
		storeLogoImageView.image = UIImage.placeholder
		storeNameLabel.text = nil
	}
	
	open override func setupView() {
		super.setupView()
		storeNameLabel.font = fontProvider[.regular(.body)]
		storeNameLabel.textColor = feedCellsContent.storeNameLabelTextColor
		receiptBackgroundImageView.image = assetsContent.receiptBackgroundImage
	}
	
	open func configure( with feedItemViewModel: FeedItemViewModel, feedItemIndex: Int, delegate: PurchaseFeedItemDelegate ) {
		super.configure( with: feedItemViewModel, feedItemIndex: feedItemIndex )
		self.delegate = delegate
		
		Task { @MainActor in
			do {
				guard let store = try await storeDataTask?.value else { return }
				
				if let url = store.storeLogo {
					storeLogoImageView.loadImage(for: url)
				}
				
				storeNameLabel.text = store.storeName
			} catch {
				Log.technical.log(.error, "Can't load store with this id: \(error)", [.identifier("PurchaseFeedItemCell.configureWithFeedItemViewModel.fetchStoreData.1")])
			}
		}
	}
	
	override func performCTA() {
		delegate?.showReceiptDetails(receiptId: feedItemViewModel?.receiptId ?? "")
		feedItemViewModel?.logItemClicked()
	}
}
