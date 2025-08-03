//
//  WaterIntakeManager.swift
//  LifeHub
//
//  Created by Kiro AI on 8/2/25.
//

import Foundation
import CoreData

class WaterIntakeManager {
    static let shared = WaterIntakeManager()
    
    private init() {}
    
    // MARK: - Core Data Operations
    
    func getAllRecords() -> [WaterIntakeRecord] {
        let context = CoreDataStack.shared.context
        let request: NSFetchRequest<WaterIntake> = WaterIntake.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
        
        do {
            let coreDataRecords = try context.fetch(request)
            return coreDataRecords.map { record in
                WaterIntakeRecord(amount: Int(record.amount), timestamp: record.timestamp ?? Date())
            }
        } catch {
            return []
        }
    }
    
    func addWaterIntake(amount: Int, timestamp: Date = Date()) {
        let context = CoreDataStack.shared.context
        
        let waterIntake = WaterIntake(context: context)
        waterIntake.amount = Int32(amount)
        waterIntake.timestamp = timestamp
        
        do {
            try context.save()
            
            // Sync to Firebase
            syncToFirebase()
            
            // Post notification
            NotificationCenter.default.post(name: .waterIntakeAdded, object: nil, userInfo: ["amount": amount])
        } catch {
            // Handle error silently
        }
    }
    
    func syncToFirebase() {
        let records = getAllRecords()
        FirebaseManager.shared.saveWaterIntake(records) { _ in }
    }
    
    func syncFromFirebase(completion: @escaping (Bool) -> Void) {
        FirebaseManager.shared.loadWaterIntake { result in
            switch result {
            case .success(let records):
                self.replaceLocalRecords(with: records)
                completion(true)
            case .failure(_):
                completion(false)
            }
        }
    }
    
    private func replaceLocalRecords(with records: [WaterIntakeRecord]) {
        let context = CoreDataStack.shared.context
        
        // Delete all existing records
        let deleteRequest: NSFetchRequest<NSFetchRequestResult> = WaterIntake.fetchRequest()
        let deleteRequestBatch = NSBatchDeleteRequest(fetchRequest: deleteRequest)
        
        do {
            try context.execute(deleteRequestBatch)
            
            // Add new records
            for record in records {
                let waterIntake = WaterIntake(context: context)
                waterIntake.amount = Int32(record.amount)
                waterIntake.timestamp = record.timestamp
            }
            
            try context.save()
        } catch {
            // Handle error silently
        }
    }
    
    // MARK: - Data Deletion
    
    func clearAllData() {
        let context = CoreDataStack.shared.context
        
        // Delete all existing records
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

extension Notification.Name {
    static let waterIntakeAdded = Notification.Name("waterIntakeAdded")
}