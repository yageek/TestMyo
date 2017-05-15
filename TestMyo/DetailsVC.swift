//
//  DetailsVC.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 16.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import CoreData

final class DetailsVC: UIViewController {

    var currentWorkout: Workout?

    private let dateFormatter: DateFormatter = {
        var formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateStyle = .long
        formatter.timeStyle = .long
        return formatter
    }()


    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!

    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var effectiveDurationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = currentWorkout?.title ?? NSLocalizedString("<no title>", comment: "Title of the details screen")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadView()
    }

    private func reloadView() {

        guard let workout = currentWorkout else { return }

        titleLabel.text = workout.title
        descriptionLabel.text = workout.workoutDescription

        typeLabel.text = workout.type
        distanceLabel.text = "\(workout.distance ?? 0)"
        startLabel.text = dateFormatter.string(from: workout.start as Date)
        endLabel.text = dateFormatter.string(from: workout.end as Date)
        createdLabel.text = dateFormatter.string(from: workout.start as Date)
        effectiveDurationLabel.text = "\(workout.effectiveDuration ?? 0)"
    }

    @IBAction func unwindToDetailsVC(_ segue: UIStoryboardSegue) { }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let navController = segue.destination as? UINavigationController, let editVC = navController.topViewController as? EditVC {
            editVC.currentWorkout = currentWorkout
        }
    }
}
