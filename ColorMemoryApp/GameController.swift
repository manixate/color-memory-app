//
//  GameController.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 2/28/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GameController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	let CellIdentifier = "CardCell"
	
	let Rows = 4
	let Columns = 4
	
	var gameBoard: [Card]
	
	private var score: Int = 0 {
		didSet {
			self.currentScoreLbl.text = "Current Score: \n\(score)";
		}
	}
	
	var highScore: Int = 0
	
	var previousSelectionIndex: Int = NSNotFound
	
	// If set to true, it allows to deselect your first card selection and no score is deducted
	var easyMode = false
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var currentScoreLbl: UILabel!
	@IBOutlet weak var highScoreLbl: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!

	required init?(coder aDecoder: NSCoder) {
		// Generate cards
		self.gameBoard = GameUtils.generateBoard(Rows, columns: Columns)
		
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
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .Right
		
		self.highScoreLbl.text = "High Score: \n\(highScore)"
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
	}
	
	override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
		return .Portrait
	}
	
	override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
		self.collectionView.collectionViewLayout.invalidateLayout()
		self.collectionView.reloadData()
	}
	
	// MARK - Actions
	@IBAction func logoPressed(sender: AnyObject) {
		
		self.navigationController!.popToRootViewControllerAnimated(true)
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
			
			// If easy mode then allows to deselect first card selection
			if (self.easyMode) {
				card.faceUp = false
				previousSelectionIndex = NSNotFound
				
				reloadCards([indexPath.row])
			}
		} else {
			card.faceUp = true
		
			if previousSelectionIndex == NSNotFound {
				// If first card selection
				previousSelectionIndex = indexPath.row
			} else {
				
				let previousCard = self.gameBoard[previousSelectionIndex]
				if previousCard.cardNumber == card.cardNumber {
					// Match
					score += 2
					
					previousCard.enabled = false
					card.enabled = false
				} else {
					// Different
					score -= 1
					
					flipCards([self.previousSelectionIndex, indexPath.row], faceUp: false, afterDelay: 1)
				}
				
				reloadCards([self.previousSelectionIndex])
				
				previousSelectionIndex = NSNotFound
			}
			
			reloadCards([indexPath.row])
		}
		
		// Check if game is finished
		let count = gameBoard.filter({ $0.enabled }).count
		if (count == 0) {
			GameUtils.askUserName(self, callback: { (name) -> () in
				
				if let player = GameUtils.saveName(name, score: self.score) {
					GameUtils.showPlayerInfo(player, controller: self)
				}
			})
		}
	}
	
	func flipCards(indexes: [Int], faceUp: Bool, afterDelay delay: NSTimeInterval) {
		// Disable all user actions
		self.view.userInteractionEnabled = false
		
		let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			[unowned self] in
			
			for index in indexes {
				let card = self.gameBoard[index]
				card.faceUp = faceUp
			}
			
			self.reloadCards(indexes)
			
			self.view.userInteractionEnabled = true
		})
	}
	
	func reloadCards(indexes: [Int]) {
		let indexPaths = indexes.map({ (index) -> NSIndexPath in
			return NSIndexPath(forRow: index, inSection: 0)
		})
		
		self.collectionView.reloadItemsAtIndexPaths(indexPaths)
	}
	
}