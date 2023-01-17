//
//  FeedsAPIProtocol.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 14.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation

public protocol FeedsAPI {
	func getActiveFeeds( completion: @escaping ( Result<[FeedItemViewModel], Error> ) -> Void )
}
