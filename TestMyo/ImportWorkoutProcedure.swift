//
//  ImportWorkoutProcedure.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import CoreData
import APIKit

final class ImportWorkoutProcedure: Procedure, InputProcedure {

    var input: Pending<Resource<ParsedWorkout>> = .pending
    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {

        let importContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        importContext.persistentStoreCoordinator = context.persistentStoreCoordinator
        importContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy

        self.context = importContext
        super.init()

        name = "Import Workout operations"
    }

    override func execute() {
        guard let resource = input.value else {
            finish(withError: ProcedureKitError.requirementNotSatisfied())
            return
        }

        var importingElements: [ParsedWorkout] = []

        switch resource {
            case let .single(element): importingElements.append(element)
            case let .collection(elements): importingElements.append(contentsOf: elements)
            case .none:
                print("Nothing to import")
                self.finish()
                return
        }

        context.perform {

            for remoteWorkout in importingElements {

                let workout = NSEntityDescription.insertNewObject(forEntityName: "Workout", into: self.context) as! Workout

                workout.identifier = remoteWorkout.ID
                workout.title = remoteWorkout.title
                workout.type = remoteWorkout.type
                workout.distance = NSDecimalNumber(value: remoteWorkout.distance)
                workout.location = remoteWorkout.location
                workout.start = remoteWorkout.start as NSDate
                workout.end = remoteWorkout.end as NSDate
                workout.created = remoteWorkout.created as NSDate
                workout.workoutDescription = remoteWorkout.workoutDescription
                
                if let value = remoteWorkout.targetDuration {
                    workout.targetDuration = NSDecimalNumber(value: value)
                }

                if let value = remoteWorkout.effectiveDuration {
                    workout.effectiveDuration = NSDecimalNumber(value: value)
                }

                workout.data = remoteWorkout.data as NSObject?
            }

            if self.context.hasChanges {
                do {

                    try self.context.save()
                } catch let error {
                    self.finish(withError: error)
                    return
                }
            }
            self.finish()
        }
    }

}
