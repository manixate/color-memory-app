//
//  GameController.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 2/28/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import UIKit

class GameController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	let CellIdentifier = "CardCell"
	
	let Rows = 4
	let Columns = 4
	
	let gameBoard: [Card]
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var currentScoreLbl: UILabel!
	@IBOutlet weak var highScoreBtn: UIButton!
	@IBOutlet weak var collectionView: UICollectionView!

	required init?(coder aDecoder: NSCoder) {
		// Generate cards
		self.gameBoard = GameController.generateBoard(Rows, columns: Columns)
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLayoutSubviews() {
		let size = self.collectionView.bounds.size
		
		var itemSize = CGSize()
		itemSize.width = size.width / CGFloat(Columns) - 10
		itemSize.height = size.height / CGFloat(Rows) - 10
		
		let layout = UICollectionViewFlowLayout()
		layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
		layout.itemSize = itemSize;
		layout.minimumInteritemSpacing = 2.5;
		layout.minimumLineSpacing = 5;
		
		self.collectionView.collectionViewLayout = layout;
		self.collectionView.contentOffset = CGPointMake(0, 0);
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(5 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
			for card in self.gameBoard {
				card.faceUp = false
			}
			
			self.collectionView.reloadData()
		}
	}
	
	// MARK - Actions
	@IBAction func highScoreBtnPressed(sender: UIButton) {
	}
	
	// MARK - UICollectionViewDataSource
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Rows * Columns
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdentifier, forIndexPath: indexPath) as! CardCell
		
		let card: Card = self.gameBoard[indexPath.row]
		cell.card = card

		cell.reload()
		
		return cell
	}
	
	// MARK - UICollectionViewDelegate
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
	}
	
	// MARK - Private Methods
	class func generateBoard(rows: Int, columns: Int) -> [Card] {
		var board: [Card] = Array()
		
		var cardNumber = 0
		for _ in 0 ..< rows {
			for _ in 0 ..< columns {
				let card = Card(cardNumber: cardNumber++ / 2)
				board.append(card)
			}
		}
		
		return board
	}
}