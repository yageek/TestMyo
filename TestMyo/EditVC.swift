//
//  EditVC.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 16.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import Eureka
import PKHUD
import ProcedureKit
import APIKit

final class EditVC: FormViewController {

    var queue = OperationQueue()
    var currentWorkout: Workout?

    override func viewDidLoad() {
        super.viewDidLoad()

        let workoutTitle = currentWorkout?.title ?? ""

        self.title = String(format: NSLocalizedString("Editing: %@", comment: "Editing title"), workoutTitle)

        self.loadForm()
    }

    @IBAction func saveTriggered(_ sender: Any) {
        triggerUpdate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    private func triggerUpdate() {

        self.view.endEditing(true)
        
        guard let ID = currentWorkout?.identifier else { return }

        let values = form.values()

        let change = ParsedEditWorkout(title: values["title"] as? String ?? "", workoutDescription: values["description"] as? String ?? "")
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let editOperation = EditWorkoutProcedure(context: context, ID: ID, update: change, successBlock: {
            HUD.flash(.success, delay: 0.7, completion: { (_) in
                self.dismiss(animated: true)
            })

        }) { (error) in
            print("Impossible to update wokout \(self.currentWorkout): \(error)")
            HUD.flash(.error, delay: 1.0)
        }

        let view = PKHUDProgressView()
        view.subtitleLabel.text = NSLocalizedString("Updating ...", comment: "")
        PKHUD.sharedHUD.contentView = view
        PKHUD.sharedHUD.show()


        queue.addOperation(editOperation)
    }

    private func showAlert() {
        let controller = UIAlertController(title: NSLocalizedString("An error occured", comment: "Alert update title"), message: NSLocalizedString("Impossible to update the workout. Please try again later", comment: "Alert update content"), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(controller, animated: true)
    }

    private func loadForm() {

        navigationOptions = [.Disabled]
        form = form +++ Section(NSLocalizedString("General Informations section", comment: "General Informations sections"))
            <<< TextRow(){ row in
                row.title = NSLocalizedString("Title", comment: "Title in edit text field.")
                row.tag = "title"
                row.value = currentWorkout?.title ?? ""
            }
            <<< TextAreaRow(){ row in
                row.title = NSLocalizedString("Description", comment: "Description in edit text field.")
                row.tag = "description"
                row.value = currentWorkout?.workoutDescription ?? ""
        }


    }
}
