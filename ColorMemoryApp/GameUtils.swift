//
//  GameCommon.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 3/2/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class GameUtils {
	// MARK - Class Methods
	
	// Generate board
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
	
	// Shuffle the board using Fisher–Yates shuffle
	class func shuffleBoard(inout board: [Card]) {
		let count = board.count
		for i in 0..<(count - 1) {
			let j = Int(arc4random_uniform(UInt32(count - i))) + i
			if (i != j) {
				swap(&board[i], &board[j])
			}
		}
	}
	
	// Ask user name. If nothing is given then ask again until valid name is given or cancelled
	class func askUserName(controller: UIViewController, callback: (name: String) -> ()) {
		let alert = UIAlertController(title: "Game Finished", message: "Please enter your name", preferredStyle: .Alert)
		alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
			textField.placeholder = "Your name"
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
			controller.navigationController!.popToRootViewControllerAnimated(true)
		}
		
		let okAction = UIAlertAction(title: "OK", style: .Default) { (action) -> Void in
			let text = alert.textFields!.first!.text
			
			guard let name = text where name.characters.count > 0 else {
				GameUtils.askUserName(controller, callback: callback)
				
				return
			}
			
			callback(name: name)
		}
		
		alert.addAction(cancelAction)
		alert.addAction(okAction)
		
		controller.presentViewController(alert, animated: true, completion: nil)
	}
	
	// Save name and score to database
	class func saveName(name: String, score: Int) -> Player? {
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
	
	// Show player info dialog
	class func showPlayerInfo(player: Player, controller: UIViewController) {
		let ranking = currentRanking(player.score)
		
		let alert = UIAlertController(title: "Congrats \(player.name)", message: "Score: \(player.score), Rank: \(ranking)", preferredStyle: .Alert)
		
		let okAction = UIAlertAction(title: "OK", style: .Default, handler: { action  in
			controller.navigationController!.popToRootViewControllerAnimated(true)
		})
		
		alert.addAction(okAction)
		
		controller.presentViewController(alert, animated: true, completion: nil)
	}
	
	// Returns current ranking based on score. If the scores are same then the latest entry is considered higher rank
	class func currentRanking(score: Int) -> Int {
		let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		let fetchRequest = NSFetchRequest(entityName: "Player")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: true)]
		fetchRequest.predicate = NSPredicate(format: "score > %@", argumentArray: [Int(score)])
		
		let errorPointer = NSErrorPointer()
		let count = managedObjectContext.countForFetchRequest(fetchRequest, error: errorPointer)
		
		return count + 1
	}
}