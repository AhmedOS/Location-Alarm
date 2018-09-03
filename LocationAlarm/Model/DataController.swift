//
//  DataController.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/13/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let container: NSPersistentContainer
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    init(modelName: String, load: Bool) {
        container = NSPersistentContainer(name: modelName)
        if load {
            self.load()
        }
    }
    
    func load(completion: (() -> Void)? = nil) {
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
        }
        //autoSaveViewContext()
        completion?()
    }
    
    func getAlarm(with id: String) -> Alarm! {
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        let predicate = NSPredicate(format: "id = \(id)")
        request.predicate = predicate
        var result: [Alarm]!
        do {
            result = try viewContext.fetch(request)
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
        return result.count == 0 ? nil : result[0]
    }
    
    func getAvailableId() -> String {
        for i in (0 ..< Int.max) {
            if getAlarm(with: String(i)) == nil {
                return String(i)
            }
        }
        return "-1"
    }
    
    func autoSaveViewContext(interval: TimeInterval = 30) {
        guard interval > 0 else {
            print("negative interval")
            return
        }
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveViewContext(interval: interval)
        }
    }
    
}
