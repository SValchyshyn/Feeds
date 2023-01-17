//
//  FeedsAPI.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 06.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation
import AuthenticationData
import CoopCore

public final class FeedsWebService {
	public init() { }
}

extension FeedsWebService: FeedsAPI {
	public func getActiveFeeds( completion: @escaping ( Result<[FeedItemViewModel], Error> ) -> Void ) {
		let endpoint: FeedsEndpoint = .activeFeeds
		
		do {
			let request: URLRequest = try .init( for: endpoint, httpMethod: endpoint.httpMethod )
			let dateFormatter = DateFormatter.iso8601FormatterWithMilliseconds
			
			URLSession.core.execute( request, auth: endpoint.tokenRequest, errorIdentifier: endpoint.errorIdentifier, dateFormatter: dateFormatter ) { ( result: Result<FeedItemList, Error> ) in
				switch result {
				case .success( let feedItems ):
					completion( .success( feedItems.feed.compactMap { .init( feedItem: $0 ) }))
					
				case .failure( let error ):
					completion( .failure( error ))
				}
			}
		} catch let error {
			completion( .failure( error ))
		}
	}
}
