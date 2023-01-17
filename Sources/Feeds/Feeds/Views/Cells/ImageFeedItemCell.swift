//
//  ImageFeedItemCell.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 05.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit
import CoreUserInterface
import Log

public protocol FeedImageCellDelegate: AnyObject {
	func reloadFeedRowAt( index: Int )
}

class ImageFeedItemCell: FeedItemCell {
	// MARK: IBOutlets
	@IBOutlet weak var mediaImageView: AsyncImageView!
	@IBOutlet weak var bottomMessageLabel: UILabel!
	@IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
	
	private weak var delegate: FeedImageCellDelegate?
	
	override func reset() {
		super.reset()
		mediaImageView.cancelLoading()
		mediaImageView.image = UIImage.placeholder
		bottomMessageLabel.attributedText = nil
	}
	
	func configure( with feedItemViewModel: FeedItemViewModel, feedItemIndex: Int, delegate: FeedImageCellDelegate ) {
		super.configure( with: feedItemViewModel, feedItemIndex: feedItemIndex )
		self.delegate = delegate
		bottomMessageLabel.attributedText = feedItemViewModel.bottomMessage
		
		// configure image with url
		if let imageUrl = feedItemViewModel.imageUrl {
			loadMediaImageFrom( url: imageUrl, feedItemViewModel: feedItemViewModel, feedItemIndex: feedItemIndex )
		} else {
			mediaImageView.isHidden = true
		}
	}
}

// MARK: Private methods
private extension ImageFeedItemCell {
	func loadMediaImageFrom( url: URL, feedItemViewModel: FeedItemViewModel, feedItemIndex: Int ) {
		// preconfigure image height before downloading
		if feedItemViewModel.feedType == .video && feedItemViewModel.imageHeight == 0 {
			// Pre setting for mediaImageView height, if feedItemViewModel.imageHeight == 0 (It can be if no image was in model at all, or URL for preview was not valid).
			// to prevent bad UI behavior, when preview image will not downloaded for video, and cell is broken.
			// In this case we set standart 2:1 frame with colorCore background (background is set only for videocell, and it sets in VideoItemFeedCell.setupView()).
			imageViewHeightConstraint.constant = mediaImageView.frame.size.width / 2
		} else {
			imageViewHeightConstraint.constant = feedItemViewModel.imageHeight
		} 
		
		// then load image from url
		mediaImageView.loadImage(for: url) { [weak self] result in
			guard let self = self else { return }
			
			switch result {
			case .success(let image):
				self.set(image: image, feedItemViewModel: feedItemViewModel, feedItemIndex: feedItemIndex)
				
			case .failure(let error):
				self.handleImageDownloadError(error)
			}
		}
	}
	
	func handleImageDownloadError(_ error: Error) {
		guard Thread.isMainThread else { return DispatchQueue.main.async { self.handleImageDownloadError( error ) } }

		// here we check if previously we called reset(), which leads to assigning default image to mediaImageView
		// so, if we triggered cancel() manually, do not log error, otherwise - log it
		if mediaImageView.image != UIImage.placeholder {
			Log.technical.log(.error, "Error loading image for ImageFeedItemCell: \(error)", [.identifier("feeds.mediaImageView.loadImage.1")])
		}
	}
	
	private func set(image: UIImage = .placeholder, feedItemViewModel: FeedItemViewModel, feedItemIndex: Int) {
		DispatchQueue.main.async {
			let aspectRatio = self.mediaImageView.frame.size.width / image.size.width
			let imageHeight = aspectRatio * image.size.height
			// Check if we get the new image, then change contraint and set the new neight value to viewModel
			if feedItemViewModel.imageHeight != imageHeight {
				feedItemViewModel.imageHeight = imageHeight
				self.imageViewHeightConstraint.constant = imageHeight
				// This condition is created to prevent loop https://stackoverflow.com/a/37476058/3542688
				self.delegate?.reloadFeedRowAt( index: feedItemIndex )
			}
		}
	}
}
