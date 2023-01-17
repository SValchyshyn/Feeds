//
//  CustomerFeedbackFeatures.swift
//  CustomerFeedback
//
//  Created by Stepan Valchyshyn on 07.07.2022.
//  Copyright © 2022 Lobyco. All rights reserved.
//

import Foundation
import Core

public enum CustomerFeedbackFeatures: String, Feature {
	/// Feature availability flag
	case feedback

	// MARK: - Feature implementation.

	public var identifier: String {
		switch self {
		case .feedback:
			return "customer_feedback_enabled"
		}
	}
}
