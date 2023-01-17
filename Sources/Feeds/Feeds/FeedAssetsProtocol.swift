//
//  FeedAssetsProtocol.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 25.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit

public protocol FeedAssetsProtocol {
	/// Image for PurchaseFeedItemCell receiptView
	var receiptBackgroundImage: UIImage { get }
	/// Image for VideoFeedItemCell playButton
	var playButtonImage: UIImage { get }
}
