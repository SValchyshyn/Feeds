//
//  ReceiptsEndpoint.swift
//  Receipts
//
//  Created by Stepan Valchyshyn on 29.09.2020.
//  Copyright © 2020 Lobyco. All rights reserved.
//

import Foundation
import CoopCore
import AuthenticationDomain
import DefaultAppConfiguration

enum ReceiptsEndpoint: RemoteConfigurableAPIEndpoint {
	case list
	case details( receiptId: String)
	
	var configKey: String {
		return "receipts"
	}
	
	var completeUrl: URL? {
		guard let baseUrl = baseUrl, var components = URLComponents( url: baseUrl, resolvingAgainstBaseURL: true ) else {
			return nil
		}
		
		components.path.append({ () -> String in
			switch self {
			case .list:
				return "v1/Receipt/list"
				
			case .details( let receiptId ):
				return "v1/Receipt/\(receiptId)"
			}
		}())
		
		return components.url
	}
	
	var requiredScopes: [AuthScope] {
		return [ .useRefreshToken ]
	}
	
	var errorIdentifier: String {
		switch self {
		case .list:
			return "receipts.list"
		
		case .details:
			return "receipts.details"
		}
	}
}
