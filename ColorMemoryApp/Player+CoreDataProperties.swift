//
//  Player+CoreDataProperties.swift
//  ColorMemoryApp
//
//  Created by Muhammad Azeem on 3/1/16.
//  Copyright © 2016 Muhammad Azeem. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Player {

    @NSManaged var name: String
    @NSManaged var score: Int
	@NSManaged var createdAt: NSDate

}
