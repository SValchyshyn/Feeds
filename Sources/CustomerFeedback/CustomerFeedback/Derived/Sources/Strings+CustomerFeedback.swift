// swiftlint:disable all
// swift-format-ignore-file
// swiftformat:disable all
// Generated using tuist — https://github.com/tuist/tuist

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
public enum CustomerFeedbackStrings {
  /// Undo
  public static let customerFeedbackCancelButton = CustomerFeedbackStrings.tr("CustomerFeedback", "customer_feedback_cancel_button")
  /// Feel free to add a few more words to your experience. Avoid mentioning personal information.
  public static let customerFeedbackInputHint = CustomerFeedbackStrings.tr("CustomerFeedback", "customer_feedback_input_hint")
  /// What made you choose that particular smiley?
  public static let customerFeedbackOptionsTitle = CustomerFeedbackStrings.tr("CustomerFeedback", "customer_feedback_options_title")
  /// How was your shopping trip?
  public static let customerFeedbackRatingTitle = CustomerFeedbackStrings.tr("CustomerFeedback", "customer_feedback_rating_title")
  /// Send
  public static let customerFeedbackSendButton = CustomerFeedbackStrings.tr("CustomerFeedback", "customer_feedback_send_button")
  /// Thank you for your reply.\nWe strive to make your experience as good as possible.
  public static let customerFeedbackThankYouMessage = CustomerFeedbackStrings.tr("CustomerFeedback", "customer_feedback_thank_you_message")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension CustomerFeedbackStrings {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
	  let format = Bundle.module.localizedString(forKey: key, value: nil, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
// swiftlint:enable all
// swiftformat:enable all
