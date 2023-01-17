//
//  FeedsBundle.swift
//  Feeds
//
//  Created by Nazariy Vlizlo on 05.08.2020.
//  Copyright © 2020 Coop. All rights reserved.
//

import UIKit

extension UIImage {
	static var placeholder: UIImage {
		return UIImage( named: "img_placeholder" ) ?? UIImage()
	}
}

public extension UIStoryboard {
	static let feeds = UIStoryboard( name: "Feeds", bundle: .module )
}
