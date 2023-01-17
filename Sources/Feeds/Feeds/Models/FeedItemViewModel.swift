//
//  FeedItemViewModel.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 05.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import Core
import Log

public struct FetchStoreDataResponseModel {
	public var storeId: String
	public var storeName: String
	public var storeLogo: URL?
	public var chainId: String
}

public class FeedItemViewModel {
	private enum Constants {
		static let feedIdKey = "feed_id"
	}
	
	public var feedType: FeedType
	public var publishDateRaw: Date
	public var receiptId: String?
	public var storeId: String?
	var id: String
	var publishDate: String
	var order: Int
	
	// Prepared attributed string
	var title: NSAttributedString?
	var topMessage: NSAttributedString?
	var bottomMessage: NSAttributedString?
	
	var buttonText: String?
	var imageUrl: URL?
	var externalUrl: URL?
	var videoUrl: URL?
	/// value for storing image height
	var imageHeight: CGFloat = 0
	
	init( feedItem: FeedItem ) {
		id = feedItem.id
		publishDate = feedItem.publishDate.feedDateDescription()
		publishDateRaw = feedItem.publishDate
		
		order = feedItem.order
		feedType = FeedType( rawValue: feedItem.feedType ) ?? .text
		
		// Converting HTML to attributed string is complex operation that leads issues when perform it while UI configure. That is why we perform this operations while preparing view model.
		title = feedItem.title.convertHTMLToAttributedString(
			font: feedCellsContent.titleFont,
			color: feedCellsContent.titleColor)
		topMessage = feedItem.details?.topMessage?.convertHTMLToAttributedString(
			font: fontProvider[.regular(.body)],
			color: feedCellsContent.titleColor)
		bottomMessage = feedItem.details?.bottomMessage?.convertHTMLToAttributedString(
			font: fontProvider[.regular(.body)],
			color: colorsContent.bodyTextColor)
		
		buttonText = feedItem.details?.buttonText
		if let imageUrl = feedItem.details?.imageUrl {
			self.imageUrl = URL( string: imageUrl )
		}
		if let externalUrl = feedItem.details?.externalUrl {
			self.externalUrl = URL( string: externalUrl )
		}
		if let videoUrl = feedItem.details?.videoUrl {
			self.videoUrl = URL( string: videoUrl )
		}
		receiptId = feedItem.details?.receiptId
		storeId = feedItem.details?.storeId
	}
	
	public func fetchStoreDataTask() async throws -> FetchStoreDataResponseModel {
		guard let storeId = storeId else { throw DataError.missing }
			
		// load storeName and storeLogo from `Stores` module using `storeId`
		do {
			let store = try await storesRepository.getStore( storeId: storeId )
			let response = FetchStoreDataResponseModel(storeId: storeId, storeName: store.name, storeLogo: store.chain.urls.logo, chainId: store.chain.id)
			return response
		} catch {
			Log.technical.log(.error, "Can't load store with this id: \(error)", [.identifier("feedItemViewModel.initWithFeedItem.getStoreById.1")])
			throw error
		}
	}
	
	// MARK: Logging
	
	func logItemClicked() {
		Log.technical.log(.info, "Feed item clicked", [.identifier("feed.item.clicked"), .customString(key: Constants.feedIdKey, value: id)])
	}
	
	func logVideoPreviewClicked() {
		Log.technical.log(.info, "Feed item video clicked", [.identifier("feed.item.video.clicked"), .customString(key: Constants.feedIdKey, value: id)])
	}
}

// MARK: Equatable implementation
extension FeedItemViewModel: Hashable {
	public static func == (lhs: FeedItemViewModel, rhs: FeedItemViewModel) -> Bool {
		lhs.hashValue == rhs.hashValue
	}
	
	public func hash(into hasher: inout Hasher) {
		hasher.combine( values:
			            id,
						publishDate,
						title?.string,
						feedType.rawValue,
						topMessage?.string,
						bottomMessage?.string,
						buttonText,
						imageUrl?.absoluteString,
						externalUrl?.absoluteString,
						videoUrl?.absoluteString,
						receiptId,
						storeId
		)
	}
}

private extension Date {
	
	func feedDateDescription() -> String {
		relativeTimeString(
			dateFormatter: DateFormatter.timeFormatter(timezone: .fittedTimeZone),
			todayFormat: FeedsLocalizedString("news_feed_today_date"),
			yesterdayFormat: FeedsLocalizedString("news_feed_yesterday_date")
		).uppercased()
	}
	
}
