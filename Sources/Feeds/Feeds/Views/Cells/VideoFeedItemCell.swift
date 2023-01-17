//
//  VideoFeedItemCell.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 05.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import AVKit
import CoreUserInterface
import SafariServices
import CoopCore

public protocol VideoFeedItemDelegate: FeedImageCellDelegate {
	func showPlayController(videoUrl: URL)
}

class VideoFeedItemCell: ImageFeedItemCell {
	// MARK: IBOutlets
	@IBOutlet weak var videoPlayButton: UIButton!
	@IBOutlet weak var videoContainer: UIView!
		
	private weak var delegate: VideoFeedItemDelegate?
	
	override func reset() {
		super.reset()
		videoPlayButton.isHidden = false
		videoContainer.isHidden = false
	}
	
	override func setupView() {
		super.setupView()
		mediaImageView.backgroundColor = colorsContent.colorCore
		videoPlayButton.setImage( assetsContent.playButtonImage, for: .normal )
	}
	
	public func configure( with feedItemViewModel: FeedItemViewModel, feedItemIndex: Int, delegate: VideoFeedItemDelegate ) {
		super.configure( with: feedItemViewModel, feedItemIndex: feedItemIndex, delegate: delegate )
		self.delegate = delegate
		// configure video container
		if feedItemViewModel.videoUrl != nil {
			videoContainer.isHidden = false
		} else {
			videoContainer.isHidden = true
			videoPlayButton.isHidden = true
		}
	}
	
	@IBAction func playButtonAction( _ sender: UIButton ) {
		guard let videoURL = feedItemViewModel?.videoUrl else {
			return
		}
		feedItemViewModel?.logVideoPreviewClicked()
		delegate?.showPlayController(videoUrl: videoURL)
	}
}
