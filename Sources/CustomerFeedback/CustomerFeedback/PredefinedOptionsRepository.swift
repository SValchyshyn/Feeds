//
//  PredefinedOptionsRepository.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 09.12.2021.
//  Copyright © 2021 LOBYCO. All rights reserved.
//

import Foundation
import CoopCore

final class PredefinedOptionsRepository: Repository {
	/// Used to request information about `PredefinedOption`.
	private let feedbackAPI: CustomerFeedbackAPI

	/// Keeps a reference to in-memory cached options.
	private var cachedOptions: [String: [PredefinedOption]]

	/// Used to synchronize the access.
	private let syncSemaphore: DispatchSemaphore = .init( value: 1 )

	/// Used to prevent from calling `.global()` everytime we have to offload work to a background thread.
	private let syncQueue: DispatchQueue = .init( label: "iOS.PredefinedOptionsRepository.getOptions" )

	public init(feedbackAPI: CustomerFeedbackAPI) {
		self.cachedOptions = [:]
		self.feedbackAPI = feedbackAPI

		// Register as repository, so `clearAllData()` can be called when the user logs out.
		registerRepository()
	}
	
	// MAKR: - Public interface.

	/**
	Fetches the list of all the available `Parters` for the current user.

	- parameter chainName:			Needed to specify for which chaing to request predefined options.
	- parameter completion:			Called from the `DispatchQueue.main` after the response is received.
	*/
	func getOptions(for chainId: String, _ completion: @escaping ([PredefinedOption]) -> Void) {
		syncQueue.async {
			// Enter the synchronization zone.
			self.syncSemaphore.wait()
			
			if let cachedOptions = self.cachedOptions[chainId] {
				DispatchQueue.main.async {
					defer {
						// Signal the semaphore so other threads can continue execution.
						self.syncSemaphore.signal()
					}

					// The cache is still valid, use it.
					completion(cachedOptions)
				}
				return
			}

			self.feedbackAPI.getPredefinedOptions(for: chainId) { result in
				defer {
					// Signal the semaphore so other threads can continue execution.
					self.syncSemaphore.signal()
				}

				// Did the fetch succeed?
				if case .success( let options ) = result {
					// YES: Update the cache.
					self.cachedOptions[chainId] = options
					completion(options)
				}
			}
		}
	}

	/// Remove all cached data.
	public func clearAllData() {
		cachedOptions = [:]
	}
}
