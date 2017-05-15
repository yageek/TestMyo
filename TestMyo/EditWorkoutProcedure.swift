//
//  EditWorkoutProcedure.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 16.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import ProcedureKitNetwork

import CoreData
import APIKit

final class UpdateWorkoutInStoreProcedure: Procedure {
    let context: NSManagedObjectContext
    let ID: String
    let change: ParsedEditWorkout

    init(context: NSManagedObjectContext, ID: String, change: ParsedEditWorkout) {
        self.context = context
        self.ID = ID
        self.change = change

        super.init()
        name = "Update the workout with \(ID)"
    }

    override func execute() {

        guard !isCancelled else { return }
        context.perform {

            let request = NSFetchRequest<Workout>(entityName: "Workout")
            request.predicate = NSPredicate(format: "identifier == %@", self.ID)

            do {
                let workouts = try self.context.fetch(request)

                guard let workout = workouts.first else {
                    self.finish(withError: ProcedureKitError.requirementNotSatisfied())
                    return

                }

                workout.title = self.change.title
                workout.workoutDescription = self.change.workoutDescription

                try self.context.save()
                self.finish()
            } catch let error {
                self.finish(withError: error)
            }

        }
    }
}

final class EditWorkoutProcedure: GroupProcedure {

    init(context: NSManagedObjectContext, ID: String, update: ParsedEditWorkout, successBlock: @escaping () -> Void, errorBlock: @escaping (Error) ->Void) {

          let session = (UIApplication.shared.delegate as! AppDelegate).session!
        let uploadProcedure = UploadProcedure(session: session, endpoint: API.Workout.UpdateWorkout(ID: ID), object: .single(update))

        let updateProcedure = UpdateWorkoutInStoreProcedure(context: context, ID: ID, change: update)


        let observer = NetworkObserver(controller: (UIApplication.shared.delegate as! AppDelegate).networkActivityController)
        updateProcedure.add(observer: observer)
        updateProcedure.add(condition: NoFailedDependenciesCondition())
        
        updateProcedure.add(dependency: uploadProcedure)

        super.init(operations: [uploadProcedure, updateProcedure])

        addWillFinishBlockObserver { (procedure, errors) in
            if let error = errors.first {
                DispatchQueue.main.async {
                    errorBlock(error)
                }
            } else {
                DispatchQueue.main.async {
                    successBlock()
                }
            }
        }

        
    }
}
