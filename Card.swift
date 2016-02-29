//
//  Card.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 2/28/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation

class Card {
	let cardNumber: Int
	var faceUp: Bool = true
	
	init(cardNumber: Int) {
		self.cardNumber = cardNumber
	}
}
