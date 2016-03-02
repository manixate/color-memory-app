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
	
	let gameBoard: [Card]
	
	var score: Int = 0 {
		didSet {
			self.currentScoreLbl.text = "Current Score: \n\(score)";
		}
	}
	
	var highScore: Int = 0
	
	var previousSelectionIndex: Int = NSNotFound
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var currentScoreLbl: UILabel!
	@IBOutlet weak var highScoreLbl: UILabel!
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
		
		// Check if game is finished
		let count = gameBoard.filter({ $0.enabled }).count
		if (count == 0) {
			askUserName()
		}
	}
	
	func faceDownCards(indexes: [Int], afterDelay delay: NSTimeInterval) {
		// Disable all user actions
		self.view.userInteractionEnabled = false
		
		let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC)))
		dispatch_after(dispatchTime, dispatch_get_main_queue(), {
			[unowned self] in
			
			for index in indexes {
				let card = self.gameBoard[index]
				card.faceUp = false
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
	
	func askUserName() {
		let alert = UIAlertController(title: "Game Finished", message: "Please enter your name", preferredStyle: .Alert)
		alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
			textField.placeholder = "Your name"
		}

		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
			self.navigationController!.popToRootViewControllerAnimated(true)
		}
		
		let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
			let text = alert.textFields!.first!.text
			self.handleUserNameInput(text)
		}
		
		alert.addAction(cancelAction)
		alert.addAction(okAction)
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func handleUserNameInput(name: String?) {
		guard let name = name where name.characters.count > 0 else {
			askUserName()
			
			return
		}
		
		if let player = saveName(name, score: self.score) {
			showPlayerInfo(player)
		}
	}
	
	func saveName(name: String, score: Int) -> Player? {
		let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		let player = NSEntityDescription.insertNewObjectForEntityForName("Player", inManagedObjectContext: managedObjectContext) as! Player
		player.name = name
		player.score = score
		player.createdAt = NSDate()
		
		do {
			try managedObjectContext.save()
		} catch {
			return nil
		}
		
		return player
	}
	
	func showPlayerInfo(player: Player) {
		let ranking = currentRanking(player.score)
		
		let alert = UIAlertController(title: "Congrats \(player.name)", message: "Score: \(player.score), Rank: \(ranking)", preferredStyle: .Alert)
		
		let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action  in
			self.navigationController!.popToRootViewControllerAnimated(true)
		})
		
		alert.addAction(okAction)
		
		self.presentViewController(alert, animated: true, completion: nil)
	}
	
	func currentRanking(score: Int) -> Int {
		let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		let fetchRequest = NSFetchRequest(entityName: "Player")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: true)]
		fetchRequest.predicate = NSPredicate(format: "score > %@", argumentArray: [Int(score)])
		
		let errorPointer = NSErrorPointer()
		let count = managedObjectContext.countForFetchRequest(fetchRequest, error: errorPointer)
		
		return count + 1
	}
	
	// MARK - Class Methods
	class func generateBoard(rows: Int, columns: Int) -> [Card] {
		var board = [Card]()
		
		var cardNumber = 0
		for _ in 0 ..< rows {
			for _ in 0 ..< columns {
				let card = Card(cardNumber: cardNumber++ / 2)
				card.faceUp = false
				board.append(card)
			}
		}
		
		shuffleBoard(&board)
		
		return board
	}
	
	class func shuffleBoard(inout board: [Card]) {
		let count = board.count
		for i in 0..<(count - 1) {
			let j = Int(arc4random_uniform(UInt32(count - i))) + i
			if (i != j) {
				swap(&board[i], &board[j])
			}
		}
	}
	
}