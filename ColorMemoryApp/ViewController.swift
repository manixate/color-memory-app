//
//  ViewController.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 2/28/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "GameControllerSegue" {
			let controller = segue.destinationViewController as! GameController
			controller.highScore = self.getHighScore()
		}
	}
	
	// MARK - Private Methods
	func getHighScore() -> Int {
		let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		let fetchRequest = NSFetchRequest(entityName: "Player")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false)]
		fetchRequest.fetchLimit = 1
		
		do {
			let players = try managedObjectContext.executeFetchRequest(fetchRequest)
			if let player = players.first as? Player {
				return player.score
			} else {
				return 0
			}
		} catch {
			return 0
		}
	}
}

