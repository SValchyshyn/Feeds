//
//  CustomerFeedback+CoreDataClass.swift
//  CoopM16
//
//  Created by Roxana-Madalina Sturzu on 21/07/2020.
//  Copyright © 2020 Greener Pastures. All rights reserved.
//
//

import CoreData
import CoreDataManager

public final class Feedback: NSManagedObject, UpdatePolicyDelegate {
	
	public enum State: String {
		case open = "Open"
		case closed = "Closed"
	}
	
	@NSManaged public var id: Int64
	@NSManaged public var receiptId: String
	@NSManaged public var rating: Int16
	@NSManaged public var thankYouMessage: String?
	@NSManaged private var rawState: String
	
	public var state: State { State(rawValue: rawState) ?? .closed }
	
	/// Feedback is used to cache in-memory text entered in feedback field to display when UITabaleCell is reused
	public var stagedFeedback: String?
	/// Predefined options used to cache in-memory options seleceted by the user to display when UITabaleCell is reused
	public var stagedOptions: [String] = []
	
	@nonobjc public class func fetchRequest() -> NSFetchRequest<Feedback> {
		return NSFetchRequest<Feedback>( entityName: "Feedback" )
	}
	
	@discardableResult
	static func create(from feedbackData: FeedbackData, id: Int, in context: NSManagedObjectContext) -> Feedback {
		guard let newFeedback = NSEntityDescription.insertNewObject( forEntityName: "Feedback", into: context ) as? Feedback else {
			fatalError( "Entity not found" )
		}
		newFeedback.id = Int64(id)
		newFeedback.receiptId = feedbackData.receiptId
		newFeedback.rating = Int16(feedbackData.rating)
		newFeedback.rawState = feedbackData.state.rawValue
		return newFeedback
	}

	func update(with feedbackData: FeedbackData, thankYouMessage: String?) {
		self.receiptId = feedbackData.receiptId
		self.rating = Int16(feedbackData.rating)
		self.rawState = feedbackData.state.rawValue
		self.thankYouMessage = thankYouMessage
	}

	// MARK: - UpdatePolicyDelegate

	public static func deleteFetchRequests() -> [NSFetchRequest<NSFetchRequestResult>] {
		return [ Feedback.fetchRequest() ]
	}
}

extension Feedback: DecoderConfigurable {
	
	private enum CodingKeys: String, CodingKey {
		case id
		case receiptId
		case rating
		case options
		case thankYouMessage
		case rawState = "state"
	}

	// MARK: - Decodable
	public func configure ( from decoder: Decoder ) throws {
		// Decode the properties
		let container = try decoder.container( keyedBy: CodingKeys.self )

		guard let id = try container.decodeIfPresent( Int64.self, forKey: .id ) else {
			throw DecodingError.dataCorruptedError( forKey: .receiptId, in: container, debugDescription: "Missing id value for feedback." )
		}
		
		guard let receiptId = try container.decodeIfPresent( String.self, forKey: .receiptId ) else {
			throw DecodingError.dataCorruptedError( forKey: .receiptId, in: container, debugDescription: "Missing receiptId value for feedback." )
		}
		
		self.id = id
		self.receiptId = receiptId
		self.rating = ( try container.decodeIfPresent( Int16.self, forKey: .rating ) ) ?? 0
		self.rawState = ( try container.decodeIfPresent( String.self, forKey: .rawState ) ) ?? ""
		self.thankYouMessage = try container.decodeIfPresent(String.self, forKey: .thankYouMessage)
	}
}
