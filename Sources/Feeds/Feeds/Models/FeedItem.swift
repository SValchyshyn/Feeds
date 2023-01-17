//
//  FeedItemModel.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 07.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation

struct FeedItemList: Decodable {
	var feed: [FeedItem]
}

struct FeedItem: Decodable {
	var id: String
	var feedType: String
	var publishDate: Date
	var title: String
	var order: Int
	var details: FeedItemDetails?
}
