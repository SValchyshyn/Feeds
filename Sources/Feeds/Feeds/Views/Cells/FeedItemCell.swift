//
//  FeedItemCell.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 05.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import CoreUserInterface
import RemoteLog
import Core

open class FeedItemCell: UITableViewCell {
	// MARK: Constants
	private enum Constants {
		static let mainButtonBorderWidth: CGFloat = 1.0
		static let mainButtonCornerRadius: CGFloat = 4.0
		static let mainButtonContentEdgeSpacing: CGFloat = 15
	}
	// MARK: IBOutlets
	@IBOutlet weak var publishedDateLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var topMessageLabel: UILabel!
	@IBOutlet weak var mainButton: RoundCornerButton!
	@IBOutlet weak var mainButtonContainer: UIView!
	@IBOutlet weak var separatorView: UIView!
	@IBOutlet weak var separatorStack: UIStackView!
	@IBOutlet weak var separatorBottomDarkView: UIView!
	
	public var feedItemViewModel: FeedItemViewModel?
	/// Store data load task. Getting cancelled once we reuse `FeedItemCell`
	public var storeDataTask: Task<FetchStoreDataResponseModel, Error>?
	
	@InjectableSafe	fileprivate var layoutProvider: LayoutProtocol?
	
	// MARK: Public methods
	public override func awakeFromNib() {
		super.awakeFromNib()
		// Clear placeholder values.
		reset()
		setupView()
	}
	
	public override func prepareForReuse() {
		super.prepareForReuse()
		// Clear placeholder values.
		reset()
	}
	
	func reset() {
		// Reset all sub-labels
		feedItemViewModel = nil
		publishedDateLabel.text = nil
		titleLabel.attributedText = nil
		topMessageLabel.attributedText = nil
		
		mainButton.setTitle( nil, for: .normal )
		mainButtonContainer?.isHidden = false
		separatorStack.isHidden = false
		
		// Cancel and reset store data fetch task
		storeDataTask?.cancel()
		storeDataTask = nil
	}
	
	/**
	Configure cell with FeedItem viewModel.
	- parameter feedItemViewModel: FeedItemViewModel model
	- parameter feedItemIndex: index of feed item view
	*/
	func configure( with feedItemViewModel: FeedItemViewModel, feedItemIndex: Int ) {
		self.feedItemViewModel = feedItemViewModel
		publishedDateLabel.text = feedItemViewModel.publishDate
		
		titleLabel.attributedText = feedItemViewModel.title
		topMessageLabel.attributedText = feedItemViewModel.topMessage
		
		if let buttonText = feedItemViewModel.buttonText {
			mainButton.setTitle( buttonText, for: .normal )
		} else {
			mainButtonContainer?.isHidden = true
		}
		
		// Cache the task to cancel if cell `reset()` call
		storeDataTask = .init{ try await feedItemViewModel.fetchStoreDataTask() }
	}
	
	func setupView() {
		publishedDateLabel.font = fontProvider.feedDateFont
		publishedDateLabel.textColor = feedCellsContent.dateTextColor
		// setup main button
		mainButton.titleLabel?.font = fontProvider[.medium(.body)]
		mainButton.setTitleColor( colorsContent.primaryColor, for: .normal )
		mainButton.layer.borderColor = colorsContent.primaryColor.cgColor
		mainButton.layer.borderWidth = Constants.mainButtonBorderWidth
		mainButton.layer.cornerRadius = layoutProvider?.feedCellButtonCornerRadius ?? Constants.mainButtonCornerRadius
		mainButton.contentEdgeInsets = .init(
			top: Constants.mainButtonContentEdgeSpacing / 2,
			left: Constants.mainButtonContentEdgeSpacing,
			bottom: Constants.mainButtonContentEdgeSpacing / 2,
			right: Constants.mainButtonContentEdgeSpacing
		)
		separatorView.backgroundColor = colorsContent.colorBackground
	}
	
	func hideSeparator() {
		separatorBottomDarkView.isHidden = true
	}
	
	/// Calls when cell becomes visible on screen with currently visible rect.
	open func cellWillBeDisplayed(at rect: CGRect) {}
	
	// MARK: - Actions.
	
	@IBAction private func mainButtonAction( _ sender: UIButton ) {
		performCTA()
	}
	
	func performCTA() {
		if let externalUrl = feedItemViewModel?.externalUrl, UIApplication.shared.canOpenURL( externalUrl ) {
			UIApplication.shared.open( externalUrl )
			feedItemViewModel?.logItemClicked()
		}
	}
}

extension FeedType {
	func feedCellType() -> FeedItemCell.Type {
		switch self {
		case .image:
			return ImageFeedItemCell.self
			
		case .video:
			return VideoFeedItemCell.self
			
		case .purchase:
			return PurchaseFeedItemCell.self
			
		case .text:
			return FeedItemCell.self
		}
	}
}
