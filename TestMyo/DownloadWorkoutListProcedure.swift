//
//  DownloadWorkoutListProcedure.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import ProcedureKit
import APIKit
import CoreData
import ProcedureKitMobile

final class DownloadWorkoutListProcedure: GroupProcedure {

    init(context: NSManagedObjectContext, successBlock: @escaping () -> Void, errorBlock: @escaping (Error) -> Void) {

        let session = (UIApplication.shared.delegate as! AppDelegate).session!

        let downloadWorkoutProcedure = DownloadProcedure<API.Workout, ParsedWorkout>(session: session,endpoint: API.Workout.GetWorkoutPage)
        let importProcedure = ImportWorkoutProcedure(context: context)

        importProcedure.injectResult(from: downloadWorkoutProcedure)
        let observer = NetworkObserver(controller: (UIApplication.shared.delegate as! AppDelegate).networkActivityController)
        downloadWorkoutProcedure.add(observer: observer)

        super.init(operations: [downloadWorkoutProcedure, importProcedure])
        name = "Get workout procedure"

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
