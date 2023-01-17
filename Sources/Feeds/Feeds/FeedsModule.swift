//
//  FeedsModule.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 05.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import Foundation
import Core
import CoreUserInterface
import Stores

final class FeedsModule {
	// MARK: - Singleton
	public static let shared = FeedsModule()
	private init() {}
	
	// MARK: - Injectables
	@Injectable fileprivate var storesRepository: StoresRepository
	@Injectable fileprivate var fontProvider: PlatformFontProvider
	@Injectable fileprivate var colorsContent: ColorsProtocol
	@Injectable fileprivate var assetsContent: FeedAssetsProtocol
	@Injectable fileprivate var feedCellsContent: FeedCellsContentProtocol
}

let storesRepository = FeedsModule.shared.storesRepository
let fontProvider = FeedsModule.shared.fontProvider
let colorsContent = FeedsModule.shared.colorsContent
let assetsContent = FeedsModule.shared.assetsContent
let feedCellsContent = FeedsModule.shared.feedCellsContent
