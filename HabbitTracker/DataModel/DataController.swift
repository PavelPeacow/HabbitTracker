//
//  DataController.swift
//  HabbitTracker
//
//  Created by Павел Кай on 13.06.2022.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "HabbitTracker")
    
    init() {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failed to load \(error.localizedDescription)")
            }
        }
    }
}
