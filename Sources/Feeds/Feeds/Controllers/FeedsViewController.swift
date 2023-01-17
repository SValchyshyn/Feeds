//
//  FeedsViewController.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 14.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import Core
import CoreUserInterface
import Receipts
import Log

open class FeedsViewController: UIViewController {
	// MARK: Constants
	private enum Constants {
		static let tableViewCellEstimatedRow: CGFloat = 400.0
		static let tableViewCellContentInset: UIEdgeInsets = .init( top: 0.0, left: 0, bottom: 15, right: 0 )
	}
	// MARK: IBOutlets:
	@IBOutlet public weak var tableView: UITableView!
	@IBOutlet public weak var headerView: UIView!
	@IBOutlet private weak var tableBottomBackgroundView: UIView!
	
	@Injectable
	private var feedWebSerview: FeedsAPI
	
	// Cache that is used to store cell heighs to improve scrolling
	public var cellsHeightCacheByItemIDs = [String: CGFloat]()
	
	// MARK: Public variables
	/// Used to create the pan and snap effects of the feed.
	public var bottomSheetPresentationManager: BottomSheetPresentationManager? {
		didSet {
			bottomSheetPresentationManager?.delegate = self
			// Add a pan gesture to the header of the bottom sheet.
			bottomSheetPresentationManager?.addPanGestureRecognizer( to: headerView )
		}
	}
	
	public var feedItems: [FeedItemViewModel] = [] {
		didSet {
			DispatchQueue.main.async {
				if self.feedItems.count == 0 {
					self.bottomSheetPresentationManager?.hide()
				} else {
					self.bottomSheetPresentationManager?.unhide()
				}
			}
		}
	}
	
	// MARK: ViewController Lifecycle
	open override func viewDidLoad() {
		super.viewDidLoad()
		resetFrontPageState()
		setupView()
	}
	
	public override func viewDidAppear( _ animated: Bool ) {
		loadFeeds()
	}
	
	// MARK: IBActions
	@IBAction func feedHeaderTapAction( _ sender: UITapGestureRecognizer ) {
		// Snap the container.
		bottomSheetPresentationManager?.snap()
	}
}

// MARK: Public methods
public extension FeedsViewController {	
	func resetFrontPageState() {
		if tableView.contentOffset != .zero {
			// If we're not scrolled to the North blobs, then reset the feed position.
			tableView.scrollToRow( at: [ 0, 0 ], at: .top, animated: true )
		} else if feedItems.isEmpty == false {
			// Snap the feed to make it partially displayed.
			bottomSheetPresentationManager?.snap( to: .partiallyDisplayed )
		}
	}
	
	/// Get current active feeds
	/// - Parameter success: success: callback that will caled if we successfully get feeds, nil by default
	func loadFeeds( success: (() -> Void)? = nil ) {
		feedWebSerview.getActiveFeeds { [ weak self ] result in
			switch result {
			case .success( let feeds ):
				DispatchQueue.main.async {
					// Do not update Feeds, when new feeds are the same and they're not empty
					if ( self?.feedItems == feeds && self?.feedItems.isEmpty != true ) ||
						// Or new feeds are empty and old feeds are not
						( self?.feedItems.isEmpty == false && feeds.isEmpty ) {
						success?()
					} else {
						// Otherwise, we'll update the feeds viewModel
						self?.feedItems = feeds
						self?.tableView.reloadData()
						success?()
					}
				}
				
			case .failure( let error ):
				Log.technical.log(.error, "Error loading feeds: \(error)", [.identifier("feeds.getFeeds.1")])
			}
		}
	}
}

// MARK: Private methods
private extension FeedsViewController {
	func setupView() {
		// Since the rows have dynamic height, provide any sort of estimateRowHeight in order to prevent
		// weird layout problems. https://stackoverflow.com/q/26774126 the images provided in the issue seems like
		// the same behavior described in https://dev.azure.com/coopitdevelopment/DCX/_workitems/edit/44887
		tableView.estimatedRowHeight = Constants.tableViewCellEstimatedRow
		// Register cell types for supported feed items.
		registerCells()
		// Add content inset so the spring effect doesn't show the background, but the feed instead.
		tableView.contentInset = Constants.tableViewCellContentInset
		// Inset scroll indicator by the same amount so it is not clipped by tab bar.
		tableView.scrollIndicatorInsets = tableView.contentInset
		tableBottomBackgroundView.backgroundColor = colorsContent.colorBackground
		// Initial hide feeds, in case of an error loading(showing empty tableView)
		bottomSheetPresentationManager?.hide()
	}
	
	func registerCells() {
		tableView.register( ImageFeedItemCell.self )
		tableView.register( VideoFeedItemCell.self )
		tableView.register( PurchaseFeedItemCell.self )
		tableView.register( FeedItemCell.self )
	}
		
	private func showCouldNotLoadReceiptAlert() {
		let alert = BasicAlertViewController( title: CoreLocalizedString( "error_generic_action_title" ), message: ReceiptsLocalizedString( "error_receipts_unavailable_body" ), topAction: .okAction(), bottomAction: nil, presentationStyle: .fullWidth )
		UIViewController.topViewController()?.present( alert, animated: true )
	}
	
	private func findVisibleCellRects(for cells: [UITableViewCell]? = nil) {
		(cells ?? tableView.visibleCells).forEach { cell in
			// Calculate cell frame relative to currently visible frame on screen
			guard let feedCell = cell as? FeedItemCell, let mainView = mainViewController()?.view else { return }
			let cellFrameInMainView = tableView.convert(feedCell.frame, to: mainView)
			
			// Check wether feed cell is actually visible, and calculate visible frame
			guard mainView.frame.intersects(cellFrameInMainView) else { return }
			let intersection = mainView.frame.intersection(cellFrameInMainView)
			feedCell.cellWillBeDisplayed(at: CGRect(origin: .zero, size: intersection.size))
		}
	}
}

extension FeedsViewController: BottomSheetPresentationDelegate {
	public func shouldScrollContentToTop() {
		// Make sure that if we snap, we also want the content to be scrolled to the top.
		// This is mainly for the situation in which we're trying to snap to partially displayed
		// and the content inside the collectionView is scrolled.
		if tableView.contentOffset != .zero {
			tableView.scrollToRow( at: [ 0, 0 ], at: .top, animated: false )
		}
	}

	public func sheetPositionWillChange( positioning: SheetPositioning ) { }
	
	public func sheetPositionDidChange() {
		guard bottomSheetPresentationManager?.state == .fullyDisplayed else { return }
		findVisibleCellRects()
	}
}

extension FeedsViewController: UITableViewDataSource {
	public func tableView( _ tableView: UITableView, numberOfRowsInSection section: Int ) -> Int {
		return feedItems.count
	}
	
	open func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
		let feedItem = feedItems[ indexPath.row ]
		
		switch feedItem.feedType {
		case .image:
			let imageCell = tableView.dequeue( ImageFeedItemCell.self, for: indexPath )
			imageCell.configure( with: feedItem, feedItemIndex: indexPath.row, delegate: self )
			return imageCell
			
		case .video:
			let videoFeedCell = tableView.dequeue( VideoFeedItemCell.self, for: indexPath )
			videoFeedCell.configure( with: feedItem, feedItemIndex: indexPath.row, delegate: self )
			return videoFeedCell
			
		case .purchase:
			let purchaseCell = tableView.dequeue( PurchaseFeedItemCell.self, for: indexPath )
			purchaseCell.configure( with: feedItem, feedItemIndex: indexPath.row, delegate: self )
			return purchaseCell
			
		case .text:
			let textCell = tableView.dequeue( FeedItemCell.self, for: indexPath )
			textCell.configure( with: feedItem, feedItemIndex: indexPath.row )
			return textCell
		}
	}
}

extension FeedsViewController: UITableViewDelegate {
	public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
		// Forward scroll event to bottom sheet manager.
		bottomSheetPresentationManager?.scrollViewWillBeginDragging( scrollView )
	}
	
	public func scrollViewDidScroll( _ scrollView: UIScrollView ) {
		// Forward scroll event to bottom sheet manager.
		bottomSheetPresentationManager?.scrollViewDidScroll( scrollView )
		findVisibleCellRects()
	}
	
	public func scrollViewWillEndDragging( _ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint> ) {
		// Forward scroll event to bottom sheet manager.
		bottomSheetPresentationManager?.scrollViewWillEndDragging( scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset )
	}
	
	public func scrollViewDidEndDragging( _ scrollView: UIScrollView, willDecelerate decelerate: Bool ) {
		// Forward scroll event to bottom sheet manager.
		bottomSheetPresentationManager?.scrollViewDidEndDragging( scrollView, willDecelerate: decelerate )
	}
	
	public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = cell as? FeedItemCell else {
			return
		}
		if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
			cell.hideSeparator()
		}
		cellsHeightCacheByItemIDs[feedID(at: indexPath)] = cell.frame.height
		findVisibleCellRects()
	}
	
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		cellsHeightCacheByItemIDs[feedID(at: indexPath)] ?? Constants.tableViewCellEstimatedRow
	}
	
	public func feedID(at indexPath: IndexPath) -> String {
		feedItems[indexPath.row].id
	}
}

extension FeedsViewController: FeedImageCellDelegate {
	public func reloadFeedRowAt( index: Int ) {
		tableView.reloadRows( at: [[ 0, index ]], with: .none )
	}
}

extension FeedsViewController: VideoFeedItemDelegate {
	public func showPlayController(videoUrl: URL) {
		let playerController = PlayerController(delegate: self)
		playerController.playVideoUrl(videoUrl)
	}
}

extension FeedsViewController: PurchaseFeedItemDelegate {
	public func showReceiptDetails( receiptId: String ) {
		let receiptViewController = ReceiptWebViewController.instantiate( receiptId: receiptId )

		// Try to load receipt HTML
		Task { @MainActor in
			do {
				showLoadingSpinner( animated: true )
				let request = try await receiptViewController.generateRequest(receiptId: receiptId)
				let (data, response) = try await URLSession.core.data(for: request)
				hideLoadingSpinner( animated: true )
				guard (response as? HTTPURLResponse)?.statusCode == 200 else {
					self.showCouldNotLoadReceiptAlert()

					if let indexPath = tableView.indexPathForSelectedRow {
						tableView.deselectRow( at: indexPath, animated: true )
					}
					return
				}
				// Success loading receipt HTML
				receiptViewController.receiptData = data // Remember data so we don't have to download it again for the web view
				// Show receipt view controller
				self.present( receiptViewController, animated: true )
			} catch {
				self.showCouldNotLoadReceiptAlert()
				
				if let indexPath = self.tableView.indexPathForSelectedRow {
					self.tableView.deselectRow( at: indexPath, animated: true )
				}
			}
		}
	}
}

extension FeedsViewController: PlayerControllerDelegate {
	public func show(playerViewController: UIViewController, completion: (() -> Void)?) {
		present(playerViewController, animated: true, completion: completion)
	}
}
