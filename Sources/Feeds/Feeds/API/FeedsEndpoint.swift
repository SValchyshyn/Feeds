//
//  FeedsEndpoint.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 06.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation
import AuthenticationDomain
import CoreNetworking
import DefaultAppConfiguration

enum FeedsEndpoint {
	case activeFeeds
	
	var httpMethod: HTTPMethod {
		switch self {
		case .activeFeeds:
			return .GET
		}
	}
}

// MARK: - RemoteConfigurableAPIEndpoint implementation.

extension FeedsEndpoint: RemoteConfigurableAPIEndpoint {
	var configKey: String {
		return "feed"
	}
	
	var completeUrl: URL? {
		guard let baseUrl = baseUrl, var components = URLComponents( url: baseUrl, resolvingAgainstBaseURL: true ) else {
			return nil
		}
		
		let apiVersion = "v1"
		
		components.path.append({ () -> String in
			switch self {
			case .activeFeeds:
				return "\(apiVersion)/active"
			}
		}())
		
		return components.url
	}
	
	var requiredScopes: [AuthScope] {
		return [ .useRefreshToken ]
	}
	
	var errorIdentifier: String {
		switch self {
		case .activeFeeds:
			return "feeds.getActiveFeeds"
		}
	}
}
