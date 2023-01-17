//
//  FeedsPlatformFontProvider.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 31.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit

public protocol FeedCellsContentProtocol {
	/// Text color for dateLabel
	var dateTextColor: UIColor { get }
	/// Font for FeedItemCell title
	var titleFont: UIFont { get }
	/// Color for FeedItemCell title
	var titleColor: UIColor { get }
	/// Color for PurchaseFeedItemCell storeNameLabel
	var storeNameLabelTextColor: UIColor { get }
}
