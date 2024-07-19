//
//  StoreDataManager.swift
//  BestEats
//
//  Created by BH on 2024/07/18.
//

import CoreData
import Foundation

struct StoreDataManager {
    
    static let shared = StoreDataManager()
    
    let container: NSPersistentContainer
    
    init() {
        self.container = NSPersistentContainer(name: "RestaurantList")
        self.container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error: \(error), \(error.localizedDescription)")
            }
        }
    }
    
    func updateRestaurant(with restaurant: Restaurant, newName: String? = nil) {
        if let newName = newName {
            restaurant.name = newName
            saveContext()
        }
    }
    
    func deleteRestaurant(with restaurant: Restaurant) {
        container.viewContext.delete(restaurant)
        saveContext()
    }
    
    func saveContext() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                print("Unresolved error: \(error.localizedDescription)")
            }
        }
    }
    
}
