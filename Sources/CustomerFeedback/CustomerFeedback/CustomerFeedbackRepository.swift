//
//  CustomerFeedbackRepository.swift
//  CustomerFeedback
//
//  Created by Roxana-Madalina Sturzu on 21/07/2020.
//  Copyright © 2020 LOBYCO. All rights reserved.
//

import CoreDataManager
import CoopCore
import CoreData
import UserDefault
import Log

final public class CustomerFeedbackRepository: Repository {
	public enum Constants {
		/// `Feedback` data validity period, in seconds.
		static let feedbackDataTTL: TimeInterval = 7 * 24 * 60 * 60		// 7 days caching
	}

	private enum Keys {
		static let lastFeedbackUpdate = "lastFeedbackUpdate"
	}

	/// The last time Feedback were updated
	@PurgeableUserDefault( key: Keys.lastFeedbackUpdate, defaultValue: Date.distantPast )
	private static var lastFeedbackUpdate: Date

	// MARK: - Properties.

	private let customerFeedbackAPI: CustomerFeedbackAPI
	private let predefinedOptionsRepository: PredefinedOptionsRepository
	
	/// Keeps a reference to `CoreData` cache and a timestamp.
	private var _cachedValue: CachedValue<[Feedback]> {
		didSet {
			// Updated the persisted timestamp when the cache is updated
			CustomerFeedbackRepository.lastFeedbackUpdate = _cachedValue.timestamp
		}
	}

	/// Used to synchronize the access in `getFeedbacks`.
	private let _syncSemaphore: DispatchSemaphore = .init( value: 1 )

	/// Used to prevent from calling `.global()` everytime we have to offload work to a background thread.
	private let _syncQueue: DispatchQueue = .init( label: "iOS.CustomerFeedbackRepository.getFeedback" )

	// MARK: - Public interface.
	
	/// Used as a flag to determine wether Feedbacks has been loaded.
	public private(set) var isDataLoaded: Bool = false

	/**
	This functions returns the local, cached Feedbacks synchronously.

	- returns: The current, cached feedbacks
	*/
	public var cachedFeedbacks: [Feedback] {
		self._cachedValue.value
	}
	
	public init(customerFeedbackAPI: CustomerFeedbackAPI) {
		self.customerFeedbackAPI = customerFeedbackAPI
		predefinedOptionsRepository = PredefinedOptionsRepository(feedbackAPI: customerFeedbackAPI)
		// Init the cached value with whatever we have in the CoreData and UserDefaults.
		_cachedValue = .init( value: CustomerFeedbackRepository.fetchLocalFeedbacks(), timestamp: CustomerFeedbackRepository.lastFeedbackUpdate, timeToLive: Constants.feedbackDataTTL )

		// Register as repository, so `clearAllData()` can be called when the user logs out.
		registerRepository()
	}

	/**
	Fetches the list of all available `Feedbacks` for the current user.

	- parameter ignoreCachedData	`true` if we should request new `Feedback` data from the endpoint nevertheless.
	- parameter completion:			`.success` uses main thread fetched and valid `CoreData` objects. Called _from_ the `DispatcheQueue.main`.
	*/
	public func getFeedbacks( ignoreCachedData: Bool = false, _ completion: @escaping ( Result< [Feedback], Error > ) -> Void ) {
		_syncQueue.async {
			// Enter the synchronization zone.
			self._syncSemaphore.wait()

			// Check if we can use the cache.
			guard ignoreCachedData || !self._cachedValue.isValid else {
				DispatchQueue.main.async {
					defer {
						// Signal the semaphore so other threads can contiunue execution.
						self._syncSemaphore.signal()
					}

					// The cache is still valid, use it.
					completion( .success( self._cachedValue.value ) )
				}
				return
			}
			
			let coreDataUpdater = CoreDataUpdater<Feedback>( context: CoreDataManager.shared.mainQueueManagedObjectContext )
			
			self.customerFeedbackAPI.getFeedbacks(coreDataUpdater: coreDataUpdater) { result in
				DispatchQueue.main.async {
					defer {
						// Signal the semaphore so other threads can contiunue execution.
						self._syncSemaphore.signal()
					}
					
					switch result {
					case .success(let response):
						self.isDataLoaded = true
						// Re-fetch the objects from the main queue.
						let newFeedbacks = CustomerFeedbackRepository.fetchLocalFeedbacks()
						self._cachedValue = .init( value: newFeedbacks, timeToLive: Constants.feedbackDataTTL )
						if let feedbacks = response.feedbacks {
							// Call the completion with the new Feedbacks.
							completion( .success( feedbacks.compactMap { $0.object} ) )
						} else {
							// Call the completion with the existent Feedbacks.
							completion( .success( newFeedbacks ) )
						}
						
					case .failure(let error):
						completion( .failure( error ) )
					}
				}
			}
		}
	}
	
	/**
	Posts a feedback to the server.

	- parameter feedback:		Necesary data for the rating to be valid.
	- parameter completion:	Called after the response is received. Not called from main thread.
	*/
	func createFeedback(feedbackData: FeedbackData, completion: @escaping (_ result: Result<Feedback, Error>) -> Void) {
		customerFeedbackAPI.createFeedback(feedbackData: feedbackData) { result in
			switch result {
			case .failure( let error):
				DispatchQueue.main.async {
					Log.technical.log(.error, "Could not create Feedback: \(error)", [.identifier("Feedback.CustomerFeedbackRepository.createFeedback")])
					completion( .failure( error ) )
				}
				return

			case .success(let state):
				let context = CoreDataManager.shared.mainQueueManagedObjectContext
				context.performAndWait {
					do {
						// Add the new feedback in the current context
						Feedback.create(from: feedbackData, id: state.id, in: context)
						try context.save()
					} catch {
						// Add the feedback to list of existing feedbacks
						completion( .failure(error) )
						return
					}
					
				}
				
				// Update cached values
				let newFeedbacks = CustomerFeedbackRepository.fetchLocalFeedbacks()
				self._cachedValue = .init( value: newFeedbacks, timeToLive: Constants.feedbackDataTTL )
				if let currentFeedback = newFeedbacks.first(where: { $0.receiptId == feedbackData.receiptId }) {
					completion( .success( currentFeedback ) )
				} else {
					fatalError("New feedback not saved")
				}
			}
		}
	}

	/**
	Put updated feedback to the server.

	- parameter vote:			Necesary data for the rating to be valid.
	- parameter reference:	Id of the object for which the rating is done.
	- parameter completion:	Called after the response is received. Not called from main thread.
	*/
	func updateFeedback(feedback: FeedbackData, completion: @escaping (_ result: Result< Feedback, Error >) -> Void ) {
		customerFeedbackAPI.updateFeedback(feedbackData: feedback) { result in
			switch result {
			case .failure( let error):
				DispatchQueue.main.async {
					Log.technical.log(.error, "Could not update Feedback: \(error)", [.identifier("Feedback.CustomerFeedbackRepository.updateFeedback")])
					completion( .failure( error ) )
				}
				return

			case .success(let state):
				let context = CoreDataManager.shared.mainQueueManagedObjectContext
				context.performAndWait {
					do {
						guard let existingFeedback = self._cachedValue.value.first(where: { $0.receiptId == feedback.receiptId }) else {
							fatalError("Updating non-existent feedback")
						}
						existingFeedback.update(with: feedback, thankYouMessage: state.thankYouMessage)
						try context.save()
					} catch {
						// Add the feedback to list of existing feedbacks
						completion( .failure(error) )
						return
					}
				}
				
				// Update cached values
				let newFeedbacks = CustomerFeedbackRepository.fetchLocalFeedbacks()
				self._cachedValue = .init( value: newFeedbacks, timeToLive: Constants.feedbackDataTTL )
				if let currentFeedback = newFeedbacks.first(where: { $0.receiptId == feedback.receiptId }) {
					completion( .success( currentFeedback ) )
				} else {
					fatalError("New feedback not saved")
				}
			}
		}
	}
	
	/**
	Deletes feedback from server.
	
	- parameter reference:	Id of the object for which the feedback is done.
	- parameter completion:	Called after the response is received. Not called from main thread.
	*/
	public func deleteFeedback(with receiptId: String, completion: @escaping (_ result: Result<Void, Error >) -> Void ) {
		customerFeedbackAPI.deleteFeedback(with: receiptId) { result in
			switch result {
			case .failure( let error):
				DispatchQueue.main.async {
					Log.technical.log(.error, "Could not delete feedback: \(error)", [.identifier("Feedback.CustomerFeedbackRepository.deleteFeedback")])
					completion( .failure( error ) )
				}
				return

			case .success:
				let context = CoreDataManager.shared.mainQueueManagedObjectContext
				context.performAndWait {
					do {
						guard let feedback = self._cachedValue.value.first(where: { $0.receiptId == receiptId }) else {
							fatalError("Trying to delete non-existing feedback")
						}
					
						context.delete(feedback)
						try context.save()
						
						// Update cached values
						let newFeedbacks = CustomerFeedbackRepository.fetchLocalFeedbacks()
						self._cachedValue = .init( value: newFeedbacks, timeToLive: Constants.feedbackDataTTL )
						
						completion( .success(()) )
					} catch {
						// Add the feedback to list of existing feedbacks
						completion( .failure(error) )
					}
				}
			}
		}
	}

	/// Remove all cached data, including `CoreData`.
	public func clearAllData() {
		// Remove in-memory cached values.
		_cachedValue = .init( value: [], timestamp: .distantPast, timeToLive: Constants.feedbackDataTTL )

		// Reset the on-disk cached values as well.
		// Reset the flag to .distatPast in order to be able to fetch new data.
		CustomerFeedbackRepository.lastFeedbackUpdate = .distantPast

		// Delete entries from CoreData.
		CustomerFeedbackRepository.deleteLocalFeedbacks()
	}
}

// MARK: - Private static methods.

extension CustomerFeedbackRepository {
	/**
	Get all `Feedbacks` from `CoreData` as main thread objects.
	*/
	private static func fetchLocalFeedbacks( ) -> [Feedback] {
		var feedbacks: [Feedback] = []
		let mainMOC = CoreDataManager.shared.mainQueueManagedObjectContext

		mainMOC.performAndWait {
			let request: NSFetchRequest<Feedback> = Feedback.fetchRequest()
			do {
				feedbacks = try mainMOC.fetch( request )
			} catch {
				Log.technical.log(.error, "Error trying to fetch Feedbacks.", [.identifier("Feedback.CustomerFeedbackRepository.fetchLocalFeedbacks")])
			}
		}

		return feedbacks
	}

	/// Deletes all the `Feedback` entries from `CoreData`.
	private static func deleteLocalFeedbacks() {
		// According to [1], using an NSBatchDeleteRequest is the fastest way to delete all objects in an entity without having to load them into memory or iterate through them.
		// [1]: http://stackoverflow.com/questions/1383598/core-data-quickest-way-to-delete-all-instances-of-an-entity/1383645#1383645
		let mainMOC = CoreDataManager.shared.mainQueueManagedObjectContext
		mainMOC.performAndWait {
			// Use the fetchRequest for the NSBatchDeleteRequest.
			let deleteRequest = NSBatchDeleteRequest( fetchRequest: Feedback.fetchRequest() )

			do {
				// Perform the delete
				try mainMOC.execute( deleteRequest )
			} catch let error as NSError {
				Log.technical.log(.error, "Could not batch delete all feedbacks: \(error.localizedDescription).", [.identifier("Feedback.CustomerFeedbackRepository.deleteLocalFeedbacks")])
			}

			do {
				try mainMOC.save()
			} catch {
				Log.technical.log(.error, "Exception saving mainMOC in CoreDataManager.clearAllEntities: \(error)", [.identifier("Feedback.CustomerFeedbackRepository.deleteLocalFeedbacks")])
			}
		}
	}
}

// A public wrapper over PredefinedOptionsRepository
extension CustomerFeedbackRepository {
	/**
	Fetches the list of all the available `Parters` for the current user.

	- parameter chainName:			Needed to specify for which chaing to request predefined options.
	- parameter completion:			Called from the `DispatchQueue.main` after the response is received.
	*/
	func getOptions(for chainId: String, _ completion: @escaping ([PredefinedOption]) -> Void) {
		predefinedOptionsRepository.getOptions(for: chainId, completion)
	}
}
