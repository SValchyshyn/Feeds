//
//  CustomerFeedbackEndpoint.swift
//  CustomerFeedback
//
//  Created by Stepan Valchyshyn on 12.04.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import CoopCore
import DefaultAppConfiguration
import AuthenticationDomain

enum CustomerFeedbackEndpoint: RemoteConfigurableAPIEndpoint {
	case allActiveFeedbacks(Int)
	case createFeedback
	case updateFeedback
	case deleteFeedback(String)
	case predefinedOptions(chainId: String)

	var configKey: String {
		return "feedback"
	}
	
	var completeUrl: URL? {
		guard let baseUrl = baseUrl, var components = URLComponents( url: baseUrl, resolvingAgainstBaseURL: true ) else {
			return nil
		}
		
		components.path.append({ () -> String in
			switch self {
			case .allActiveFeedbacks:
				return "v1/feedback/recent"
				
			case .createFeedback, .updateFeedback, .deleteFeedback:
				return "v1/feedback"
				
			case .predefinedOptions(let chainId):
				return "v1/feedback/options/\(chainId)"
			}
		}())
		
		return components.url
	}
	
	var requiredScopes: [AuthScope] {
		[.useRefreshToken]
	}

	var errorIdentifier: String {
		switch self {
		case .allActiveFeedbacks:
			return "feedback.getFeedbacks"
		case .createFeedback:
			return "feedback.createFeedback"
		case .updateFeedback:
			return "feedback.updateFeedback"
		case .deleteFeedback:
			return "feedback.deleteFeedback"
		case .predefinedOptions:
			return "feedback.getOptions"
		}
	}
	
	var query: [String: String]? {
		switch self {
		case .allActiveFeedbacks(let days):
			return ["durationInDays": days.description]
			
		case .deleteFeedback(let receiptId):
			return ["receiptId": receiptId.description]
			
		default:
			return nil
		}
	}
}
