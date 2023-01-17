//
//  FeedItemDetails.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 07.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation

struct FeedItemDetails: Decodable {
	var topMessage: String?
	var bottomMessage: String?
	var buttonText: String?
	var imageUrl: String?
	var externalUrl: String?
	var videoUrl: String?
	var storeId: String?
	var receiptId: String?
}
