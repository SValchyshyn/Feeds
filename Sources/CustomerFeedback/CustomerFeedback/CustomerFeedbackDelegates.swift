//
//  AnimatableCellDelegate.swift
//  CustomerFeedback
//
//  Created by Roxana-Madalina Sturzu on 16/09/2020.
//  Copyright © 2020 LOBYCO. All rights reserved.
//

public protocol AnimatableCellDelegate: AnyObject {
	/// Content has changed and the cell should be reloaded
	func contentChanged()
}

public protocol CustomerFeedbackManagerDelegate: ThankYouViewDelegate {
	/**
	Signals that the content of the current view changed.
	*/
	func contentChanged()
	
	/**
	 Signals that the current tableview should be reloaded.
	 */
	func reloadTable()
}

public protocol CustomerFeedbackContentDelegate: AnyObject {
	/**
	Signlas that the voting part was done by the user.
	- parameter rating: 		Value of the vote given by the user (1-5).
	*/
	func ratingDone( rating: Int)

	/**
	Signlas that the voting part was done by the user.
	- parameter message: 		Comment given by the user.
	*/
	func commentDone( message: String)
	
	/**
	Signlas that selected option have been changed.
	- parameter options: 		Options been selected by the user.
	*/
	func optionsDidChange( options: [String])
	
	/**
	Signlas that the feedback text has been changed.
	- parameter message: 		Comment given by the user.
	*/
	func commentDidChange( message: String)
	
	/**
	Signals that the feedback was cancelled by the user.
	*/
	func feedbackCancelled()
}
