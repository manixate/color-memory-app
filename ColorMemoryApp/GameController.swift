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
	
	var score = 0 {
		didSet {
			self.currentScoreLbl.text = String(score);
		}
	}
	
	var previousSelectionIndex: Int = NSNotFound
	
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
	}
	
	override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
		self.collectionView.collectionViewLayout.invalidateLayout()
		self.collectionView.reloadData()
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
		
		handleCardFlip(indexPath)
	}
	
	// MARK - Private Methods
	func handleCardFlip(indexPath: NSIndexPath) {
		let card: Card = self.gameBoard[indexPath.row]
		
		if card.faceUp {
			card.faceUp = false
			previousSelectionIndex = NSNotFound
			
			collectionView.reloadItemsAtIndexPaths([indexPath])
		} else {
			card.faceUp = true
		
			if previousSelectionIndex == NSNotFound {
				previousSelectionIndex = indexPath.row
			} else {
				let previousCard = self.gameBoard[previousSelectionIndex]
				if previousCard.cardNumber == card.cardNumber {
					score += 2
					
					previousCard.enabled = false
					card.enabled = false
				} else {
					score -= 1
					
					faceDownCards([self.previousSelectionIndex, indexPath.row], afterDelay: 1)
				}
				
				reloadCards([self.previousSelectionIndex])
				
				previousSelectionIndex = NSNotFound
			}
			
			reloadCards([indexPath.row])
		}
	}
	
	func faceDownCards(indexes: [Int], afterDelay delay: NSTimeInterval) {
		let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			[unowned self] in
			
			for index in indexes {
				let card = self.gameBoard[index]
				card.faceUp = false
			}
			
			self.reloadCards(indexes)
		})
	}
	
	func reloadCards(indexes: [Int]) {
		let indexPaths = indexes.map({ (index) -> NSIndexPath in
			return NSIndexPath(forRow: index, inSection: 0)
		})
		
		self.collectionView.reloadItemsAtIndexPaths(indexPaths)
	}
	
	class func generateBoard(rows: Int, columns: Int) -> [Card] {
		var board: [Card] = Array()
		
		var cardNumber = 0
		for _ in 0 ..< rows {
			for _ in 0 ..< columns {
				let card = Card(cardNumber: cardNumber++ / 2)
				card.faceUp = false
				board.append(card)
			}
		}
		
		return board
	}
}