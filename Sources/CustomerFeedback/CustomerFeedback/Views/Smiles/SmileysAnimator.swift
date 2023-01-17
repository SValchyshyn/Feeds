//
//  SmilesAnimator.swift
//  CustomerFeedback
//
//  Created by Marian Hunchak on 23.12.2021.
//  Copyright © 2021 Lobyco. All rights reserved.
//

import Foundation
import CoopCore
import UIKit

class SmileysAnimator {
	
	private enum Constants {
		static let interval: Double = 0.25
	}
	
	private let smileButtons: [UIButton]
	private var isCancelled = false
	
	init(smiles: [UIButton]) {
		self.smileButtons = smiles.reversed() + smiles + smiles.suffix(1)
	}
	
	func start() {
		
		let start = DispatchTime.now()
		var iterator = (0..<smileButtons.count).makeIterator()

		func startNext() {
			guard !isCancelled, let index = iterator.next() else { return }
			
			let deadline = start + Double(index) * Constants.interval
			performAnimation(for: index, deadline: deadline, completion: startNext)
		}
		
		startNext()
	}

	private func performAnimation(for index: Int, deadline: DispatchTime, completion: @escaping () -> Void) {
		DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
			guard let self = self, !self.isCancelled else { return }
			
			let currentButton = self.smileButtons[index]
			let previousButton = self.smileButtons[safe: index - 1]
			
			UIView.transition(with: currentButton, duration: 0.1, options: .transitionCrossDissolve) {
				currentButton.isSelected = true
				previousButton?.isSelected = false
			}
			
			completion()
		}
	}
	
	func cancel() {
		isCancelled = true
	}
	
	deinit {
		cancel()
	}
}
