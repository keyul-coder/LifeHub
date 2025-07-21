//
//  WaterIntake+CoreDataProperties.swift
//  LifeHub
//
//  Created by Gaurav Harkhani on 05/06/25.
//

import Foundation
import CoreData

extension WaterIntake {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<WaterIntake> {
        return NSFetchRequest<WaterIntake>(entityName: "WaterIntake")
    }

    @NSManaged public var amount: Int32
    @NSManaged public var timestamp: Date?
}

extension WaterIntake : Identifiable { }
