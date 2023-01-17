//
//  ReceiptViewController.swift
//  CoopM16
//
//  Created by Nis Wegmann on 10/08/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Core
import CoreUserInterface
import CoopCore
import Log
import Tracking

public class ReceiptListViewController: MonthSectionViewController, Trackable {
	/// Returns a new instance of ReceiptListViewController
	public static func instantiate() -> ReceiptListViewController {
		return UIStoryboard.receiptList.instantiate( ReceiptListViewController.self )
	}
	
	@IBOutlet private weak var noReceiptsLabel: UILabel!
	@IBOutlet private weak var topBarView: TopBarView!
	@IBOutlet private weak var loadingSpinner: LoadingSpinner!

	// MARK: - Properties

	/// Controls whether the front page image will be used as a background of top bar.
	public var shouldShowTopBarImage: Bool = true {
		didSet { topBarView?.showImage = shouldShowTopBarImage }
	}

	/// Custom background color of the top bar. Takes effect only if the `shouldShowTopBarImage` is set to `false`.
	public var topBarBackgroundColor: UIColor? {
		didSet { topBarView?.backgroundColor = topBarBackgroundColor }
	}

	// MARK: - Dependencies
	
	@Injectable private var receiptsRepository: ReceiptsRepository
	
	// MARK: - Use cases
	
	private var getReceiptStatementsUseCase: GetReceiptStatementsUseCase!
	
	///  Flag indicating if we have loaded the last page of receipts
	private var _hasLoadedLastPage = false
	private var isLoadingData = false
	
	private var isFirstLoad = true

	// Tracking vars
	public let trackingPageId = "receipt_list"
	public let trackingPageName = "Kvitteringer"

	public override var emptySectionTitle: String {
		return stringsContent.emptySectionTitle
	}

	public override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	public override func viewDidLoad() {
		super.viewDidLoad()
		
		// Add close button
		topBarView.addCloseButtonTarget( self, action: #selector( closeAction(_:) ))

		// Show the ViewController's loading spinner
		loadingSpinner.show( animated: false )
		
		setupView()
		
		// Init use cases with an API provider
		getReceiptStatementsUseCase = GetReceiptStatementsUseCase( receiptRepository: receiptsRepository )

		// Get receipts from the API
		loadData()
	}
	
	public override func viewDidAppear( _ animated: Bool ) {
		super.viewDidAppear( animated )

		// Track page
		trackViewController( parameters: nil )
	}
	
	// Shows the receipt for the bonus transaction
	func showReceipt( _ receiptId: String ) {
		let receiptViewController = ReceiptWebViewController.instantiate( receiptId: receiptId )

		// Try to load receipt HTML
		Task { @MainActor in
			do {
				loadingSpinner.show( animated: true )
				let request = try await receiptViewController.generateRequest(receiptId: receiptId)
				let (data, response) = try await URLSession.core.data(for: request)
				loadingSpinner.hide(animated: true)
				guard (response as? HTTPURLResponse)?.statusCode == 200 else {
					if let indexPath = tableView.indexPathForSelectedRow {
						tableView.deselectRow( at: indexPath, animated: true )
					}
					throw APIError.invalidResponse
				}
				// Success loading receipt HTML
				receiptViewController.receiptData = data // Remember data so we don't have to download it again for the web view
				// Show receipt view controller
				present( receiptViewController, animated: true )
			} catch {
				showCouldNotLoadReceiptAlert()
				
				if let indexPath = tableView.indexPathForSelectedRow {
					tableView.deselectRow( at: indexPath, animated: true )
				}
			}
		}
	}
	
	private func loadData() {
		// Remember first load to close screen if failed to load data.
		let shouldDismissOnError = isFirstLoad
		
		if !isFirstLoad {
			showTableViewLoading()
		} else {
			// Show the no receipts label
			self.noReceiptsLabel.isHidden = false
			isFirstLoad = false
		}
		
		Task { @MainActor in
			do {
				let transactions = try await getReceiptStatementsUseCase.getNextPage()
				if !transactions.isEmpty {
					// Hide noReceiptsLabel
					noReceiptsLabel.isHidden = true
				}
				
				// Group the transactions by months
				process( groupableRecords: transactions )
				
				if getReceiptStatementsUseCase.isFullyLoaded {
					// Remove the tableFooterView, if will be added again.
					tableView.tableFooterView = nil
				}
				
				// Update the UI
				tableView.reloadData()
				noReceiptsLabel.isHidden = self.recordsDictionary.count > 0
				loadingSpinner.hide( animated: true )
			} catch {
				Log.technical.log(.error, "Error in ReceiptListViewController.loadData(): \(error)", [.identifier("receipts.loadData.fetchTransactions.1")])
				
				// Show alert and close the page
				showCouldNotLoadReceiptsAlert( shouldDismiss: shouldDismissOnError )
			}
		}
	}
	
	private func showTableViewLoading() {
		// Show a spinner at the bottom of the table
		let spinnerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: LoadingSpinner.Constants.defaultHeight))
		spinnerView.backgroundColor = .clear
		spinnerView.showLoadingSpinner(animated: true)
		tableView.tableFooterView = spinnerView
	}

	// MARK: - Actions

	@IBAction func closeAction( _ sender: AnyObject ) {
		popOrDismiss( animated: true )
	}
	
	// MARK: - UITableViewDataSource / UITableViewDelegate

	public override func tableView( _ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
		let cell = tableView.dequeue( ReceiptCell.self, for: indexPath )

		guard let receipt = recordsDictionary[indexPath.section]?[indexPath.row] else {
			return cell
		}

		// Configure the cell
		cell.configure( with: receipt as! ReceiptItemDomain )	// Explicit unwrap, we only stored receipts -GKD

		return cell
	}

	/**
	Due to an issue with protocol inheritance in Swift 5 we have to manually add `@objc` before protocol functions which are inherited from the superclass (without the superclass implementing them)
	We should remove the manual `@objc` declerations after this is fixed in the future versions of Swift.
	Reference: https://bugs.swift.org/browse/SR-10257
	*/
	@objc func tableView( _ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
		guard let receipt = recordsDictionary[indexPath.section]?[indexPath.row] as? ReceiptItemDomain else {
			// Could not find the receiptID
			return
		}

		// If the bonus transaction is a payment transaction show the associated receipt, otherwise show the normal bonus transaction detail page
		showReceipt( receipt.id )

		// Deselect the cell
		tableView.deselectRow( at: indexPath, animated: true )
	}

	@objc func tableView( _ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath ) {
		// Should we load the next page?
		if indexPath.section == currentMonthIndex - 1, let receiptsInSection = recordsDictionary[indexPath.section], indexPath.row == receiptsInSection.count - 1, !getReceiptStatementsUseCase.isFullyLoaded {
			loadData()
		}
	}

	// MARK: - Alerts

	func showCouldNotLoadReceiptAlert() {
		let alert = BasicAlertViewController( title: stringsContent.receiptsCommingSoonAlertTitle, message: stringsContent.receiptsCommingSoonAlertBody, topAction: .okAction(), bottomAction: nil, presentationStyle: .fullWidth )
		UIViewController.topViewController()?.present( alert, animated: true )
	}

	func showCouldNotLoadReceiptsAlert( shouldDismiss: Bool ) {
		let action = shouldDismiss ?  CustomAlertAction.okAction { _ in self.popOrDismiss( animated: true ) } : .okAction()
		let alert = BasicAlertViewController( title: stringsContent.cannotGetReceiptsAlertTitle, message: stringsContent.cannotGetReceiptsAlertBody, topAction: action, bottomAction: nil, presentationStyle: .fullWidth )
		UIViewController.topViewController()?.present( alert, animated: true )
	}
}

extension ReceiptListViewController: InAppActionable2 {
	public func inAppActionExecutor(for action: InAppAction2) -> InAppActionExecutor? {
		switch action {
		case ReceiptsInAppAction.list: return .finish
		default: return nil
		}
	}
}

private extension ReceiptListViewController {
	func setupView() {
		view.backgroundColor = colorsContent.colorBackground
		
		topBarView.title = stringsContent.receiptsListTitle
		topBarView.useDarkElements = false
		topBarView.showImage = shouldShowTopBarImage
		topBarBackgroundColor.flatMap { topBarView.backgroundColor = $0 }
		
		noReceiptsLabel.text = stringsContent.noReceiptsText
		noReceiptsLabel.font = fontProvider[.regular(.body)]
		noReceiptsLabel.textColor = colorsContent.bodyTextColor
	}
}
