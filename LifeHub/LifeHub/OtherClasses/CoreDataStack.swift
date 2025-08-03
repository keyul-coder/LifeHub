//
//  CoreDataStack.swift
//  LifeHub
//
//  Created by Smit Patel on 04/06/25.
//

import Foundation
import CoreData

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    private init() {
        persistentContainer = NSPersistentContainer(name: "LifeHub")
        persistentContainer.loadPersistentStores { (desc, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Handle error silently
            }
        }
    }
    
    // MARK: - Data Deletion
    
    func deleteAllData() {
        let context = persistentContainer.viewContext
        
        // Get all entity names from the managed object model
        guard let entityNames = persistentContainer.managedObjectModel.entities.compactMap({ $0.name }) as [String]? else {
            return
        }
        
        // Delete all data for each entity
        for entityName in entityNames {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            
            do {
                try context.execute(deleteRequest)
            } catch {
                // Handle error silently
            }
        }
        
        // Save the context to persist the deletions
        do {
            try context.save()
        } catch {
            // Handle error silently
        }
    }
    
    func deleteAllWaterIntakeData() {
        let context = persistentContainer.viewContext
        let deleteRequest: NSFetchRequest<NSFetchRequestResult> = WaterIntake.fetchRequest()
        let deleteRequestBatch = NSBatchDeleteRequest(fetchRequest: deleteRequest)
        
        do {
            try context.execute(deleteRequestBatch)
            try context.save()
        } catch {
            // Handle error silently
        }
    }
}
