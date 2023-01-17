//
//  CustomerFeedbackAPI.swift
//  CustomerFeedback
//
//  Created by Stepan Valchyshyn on 12.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core
import CoreDataManager
import CoreNetworking
import AuthenticationData

public final class CustomerFeedbackWebService: CustomerFeedbackAPI {
	private enum Constants {
		/// How old a Feedback can get. Used to fetch the data from the server.
		static let validDays: Int = 7
	}
	
	public init() {}
	
	public func getFeedbacks(coreDataUpdater: CoreDataUpdater<Feedback>, completion: @escaping ( Result<FeedbackResponse, Error> ) -> Void ) {
		Task {
			do {
				let endpoint: CustomerFeedbackEndpoint = .allActiveFeedbacks( Constants.validDays )
				let request: URLRequest = try .init( for: endpoint, httpMethod: .GET, query: endpoint.query )
				let response: FeedbackResponse = try await URLSession.core.execute( request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier, coreDataUpdater: coreDataUpdater )
				completion(.success(response))
			} catch {
				completion(.failure(error))
			}
		}
	}
	
	public func createFeedback(feedbackData: FeedbackData, completion: @escaping (Result<FeedbackState, Error>) -> Void) {
		let endpoint: CustomerFeedbackEndpoint = .createFeedback
		
		do {
			var request: URLRequest = try .init( for: endpoint, httpMethod: .POST )
			request.httpBody = try? JSONEncoder().encode(feedbackData)

			URLSession.core.execute( request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier) { ( result: Result<FeedbackState, Error> ) in
				switch result {
				case .success( let state ):
					completion( .success( state ))
					
				case .failure( let error ):
					completion( .failure( error ))
				}
			}
		} catch let error {
			completion( .failure( error ))
		}
	}
	
	public func updateFeedback(feedbackData: FeedbackData, completion: @escaping (Result<FeedbackState, Error>) -> Void) {
		let endpoint: CustomerFeedbackEndpoint = .updateFeedback
		
		do {
			var request: URLRequest = try .init( for: endpoint, httpMethod: .PUT )
			request.httpBody = try? JSONEncoder().encode(feedbackData)

			URLSession.core.execute( request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier) { ( result: Result<FeedbackState, Error> ) in
				switch result {
				case .success( let state ):
					completion( .success( state ))
					
				case .failure( let error ):
					completion( .failure( error ))
				}
			}
		} catch let error {
			completion( .failure( error ))
		}
	}
	
	public func deleteFeedback(with receiptId: String, completion: @escaping (Result<Void, Error>) -> Void) {
		let endpoint: CustomerFeedbackEndpoint = .deleteFeedback(receiptId)
		
		do {
			let request: URLRequest = try .init( for: endpoint, httpMethod: .DELETE, query: endpoint.query )

			URLSession.core.execute( request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier) { ( result: Result<EmptyResponseModel, Error> ) in
				switch result {
				case .success:
					completion( .success(()))
					
				case .failure( let error ):
					completion( .failure( error ))
				}
			}
		} catch let error {
			completion( .failure( error ))
		}
	}
	
	public func getPredefinedOptions(for chainId: String, completion: @escaping (Result<[PredefinedOption], Error>) -> Void) {
		let endpoint: CustomerFeedbackEndpoint = .predefinedOptions(chainId: chainId)
		
		do {
			let request: URLRequest = try .init( for: endpoint, httpMethod: .GET )

			URLSession.core.execute( request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier) { ( result: Result<PredefinedOptionsResponse, Error> ) in
				switch result {
				case .success( let response ):
					completion( .success( response.options ))
					
				case .failure( let error ):
					completion( .failure( error ))
				}
			}
		} catch let error {
			completion( .failure( error ))
		}
	}
}
