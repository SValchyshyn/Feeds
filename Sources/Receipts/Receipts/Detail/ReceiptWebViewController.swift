//
//  ReceiptWebViewController.swift
//  CoopM16
//
//  Created by Nis Wegmann on 15/08/2016.
//  Copyright © 2016 Greener Pastures. All rights reserved.
//

import UIKit
import Core
import CoreUserInterface
import CoopCore
import WebKit
import Log
import Tracking

public class ReceiptWebViewController: WebKitViewController, Trackable {
	/// Returns a new instance of ReceiptWebViewController
	public static func instantiate( receiptId: String ) -> ReceiptWebViewController {
		let viewController = UIStoryboard.receiptDetails.instantiate( ReceiptWebViewController.self )
		viewController.receiptId = receiptId
		
		return viewController
	}
	
	// MARK: - Outlets
	
	@IBOutlet weak var closeButton: CloseButton!
	@IBOutlet weak var topCloseButtonConstraint: NSLayoutConstraint!

	// MARK: - Properties
	
	/// Receipt ID to show details for. NB: be sure to set this before presenting the view controller as the request is loaded in viewDidLoad.
	public var receiptId: String?

	/// Preloaded HTML data
	public var receiptData: Data?

	// Tracking vars
	public let trackingPageId = "receipt_details"
	public let trackingPageName = "Kvittering"
	
	// MARK: - Dependencies
	
	@Injectable private var receiptsRepository: ReceiptsRepository

	override public func viewDidLoad() {
		super.viewDidLoad()

		// Make sure the close button is on top of the web view
		view.bringSubviewToFront( closeButton )

		guard let receiptId = receiptId else {
			// Log the error
			Log.technical.log(.error, "Missing receiptId", [.identifier("receipt.webDetails")])
			return
		}
		
		// Generate an URL request
		Task { @MainActor in
			do {
				let request = try await generateRequest(receiptId: receiptId)
				if let receiptData = self.receiptData, let baseURL = request.url {
					// Show preloaded data in web view
					self.webView.loadWithTracking( data: receiptData, mimeType: "text/html", encodingName: "UTF-8", baseURL: baseURL )
				} else {
					// Load the request with the web view
					self.webView.loadWithTracking( request )
				}
			} catch {
				Log.technical.log(.error, "Failed to get generate receipt details request: \(error)", [.identifier("receipt.webDetails")])
			}
		}

		// Show spinner
		webView.showLoadingSpinner( animated: true )
	}

	override public func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		/**
		On iPhone X, the distance to topLayoutGuide is the same regardless if the statusBar is hidden or not.
		On all other iPhones, the topLayoutGuide will be the same as the Superview.top if the statusBar is hidden.
		We need to raise the button with the 20 pixels we simulated for the statusBar.
		*/
		if view.safeAreaInsets.top > 0.0 {
			// We're on an iPhone X
			topCloseButtonConstraint.constant = 2
		}
	}

	override public func viewDidAppear( _ animated: Bool ) {
		super.viewDidAppear( animated )

		// Track page
		trackViewController( parameters: nil )
	}
	
	// MARK: - Requests

	public func generateRequest( receiptId: String) async throws -> URLRequest {
		// Generate an URL request
		let request: URLRequest = try await receiptsRepository.getReceiptDetailsRequest(receiptId: receiptId)
		return request
	}
	
	public func loadData() async throws {
		guard let receiptId = receiptId else { throw APIError.missingRequestInfo }
		
		let request = try await generateRequest(receiptId: receiptId)
		let (data, response) = try await URLSession.core.data(for: request)
		guard (response as? HTTPURLResponse)?.statusCode == 200 else { throw APIError.invalidResponse }
		self.receiptData = data
	}

	// MARK: - Actions

	@IBAction func closeAction( _ sender: AnyObject ) {
		// Go back to the receipt view controller
		dismiss( animated: true )
	}

	// MARK: - Webkit view delegate

	@objc func webView(_ webView: WKWebView, didFinish navigation: WKNavigation! ) {
		// Hide spinner after successfull load
		webView.hideLoadingSpinner( animated: true )
	}

	@objc func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error ) {
		// Hide spinner
		webView.hideLoadingSpinner( animated: true )

		// Log the error
		Log.technical.log(.error, "Error while loading receipt: \(error)", [.identifier("receipt.loadingError")])
	}
}
