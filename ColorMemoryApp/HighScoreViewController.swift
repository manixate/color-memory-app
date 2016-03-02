//
//  HighScoreViewController.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 3/2/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class HighScoreViewController: UITableViewController, NSFetchedResultsControllerDelegate {

	let fetchedResultsController: NSFetchedResultsController
	
	required init?(coder aDecoder: NSCoder) {
		let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
		
		let fetchRequest = NSFetchRequest(entityName: "Player")
		fetchRequest.sortDescriptors = [NSSortDescriptor(key: "score", ascending: false), NSSortDescriptor(key: "createdAt", ascending: false)]
		fetchRequest.fetchLimit = 10
		
		fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
		
		super.init(coder: aDecoder)
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "High Scores"
		
		do {
			try fetchedResultsController.performFetch()
		} catch {
			
		}
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		UIViewController.attemptRotationToDeviceOrientation()
		self.navigationController!.navigationBarHidden = false
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		self.navigationController!.navigationBarHidden = true
	}
	
	// MARK - UITableViewDataSource Methods
	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		if let sections = fetchedResultsController.sections {
			return sections.count
		} else {
			return 0
		}
	}
	
	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = fetchedResultsController.sections {
			return sections[section].numberOfObjects
		} else {
			return 0
		}
	}
	
	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("HighScoreCellIdentifier") as! HighScoreCell
		
		let player = fetchedResultsController.objectAtIndexPath(indexPath) as! Player
		
		cell.rankLabel.text = "\(indexPath.row + 1)"
		cell.nameLabel.text = player.name
		cell.scoreLabel.text = "\(player.score)"
		
		return cell
	}
	
	override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
		return 50
	}
	
	override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let view = UIView()
		
		let rankLabel = UILabel()
		rankLabel.text = "Rank"
		rankLabel.textAlignment = .Left
		rankLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let nameLabel = UILabel()
		nameLabel.text = "Name"
		nameLabel.textAlignment = .Center
		nameLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let scoreLabel = UILabel()
		scoreLabel.text = "Score"
		scoreLabel.textAlignment = .Right
		scoreLabel.translatesAutoresizingMaskIntoConstraints = false
		
		view.addSubview(rankLabel)
		view.addSubview(nameLabel)
		view.addSubview(scoreLabel)
		
		let viewsDictionary = ["rankLabel": rankLabel, "nameLabel": nameLabel, "scoreLabel": scoreLabel]
		
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[rankLabel(40)]-10-[nameLabel]-10-[scoreLabel(60)]-|", options: NSLayoutFormatOptions.AlignAllBaseline, metrics: nil, views: viewsDictionary))
		
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[rankLabel]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDictionary))
		
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[nameLabel]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDictionary))
		
		view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[scoreLabel]-|", options: NSLayoutFormatOptions.AlignAllCenterY, metrics: nil, views: viewsDictionary))
		
		return view
	}
	
	override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
		return UIView()
	}
}
