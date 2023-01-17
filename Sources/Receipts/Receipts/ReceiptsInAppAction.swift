//
//  ReceiptsInAppAction.swift
//  Receipts
//
//  Created by Olexandr Belozierov on 14.07.2021.
//  Copyright © 2021 Loop By Coop. All rights reserved.
//

import CoopCore

public enum ReceiptsInAppAction: InAppAction2 {
	case list
	case detail(receiptID: String)
}
