//
//  CardCell.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 2/28/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
	var card: Card?
	
	var faceUp: Bool = true
	
	var changing: Bool = false
	
	@IBOutlet weak var imageView: UIImageView!
	
	func reload() {
		if let card = self.card {
			NSLog("\(card.cardNumber)")
			if card.faceUp {
				self.imageView.image = UIImage(named: "Color\(card.cardNumber + 1)")
			} else {
				self.imageView.image = UIImage(named: "CardBackground")
			}
			
			self.faceUp = card.faceUp
		}
	}
}
