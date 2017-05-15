//
//  MasterVC.swift
//  TestMyo
//
//  Created by Yannick Heinrich on 15.12.16.
//  Copyright © 2016 yageek. All rights reserved.
//

import UIKit
import ProcedureKit
import CoreData

final class MasterVC: UITableViewController {

    let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.name = "net.yageek.MyoTest.fetchelement"
        return queue
    }()

    var fetchedResultsController: NSFetchedResultsController<Workout>?


    var backgroundLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        showEmptyElements()

        setupFetchController()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        updateUI(firstTime: true)

    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]
        return section?.numberOfObjects ?? 0
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutCell", for: indexPath) as! WorkoutCell

        if let workout = workoutAt(indexPath: indexPath) {
            cell.titleLabel.text = workout.title
            cell.subtitelLabel.text = workout.workoutDescription
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionName = fetchedResultsController?.sections?[section].name ?? "???"

        // Dequeue with the reuse identifier
        let cell = self.tableView.dequeueReusableHeaderFooterView(withIdentifier: "SectionHeader")
        let header = cell as! SectionHeader
        header.dateText.text = sectionName

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }


    @IBAction func refreshTriggered(_ sender: UIRefreshControl) {
        downloadWorkout()
    }

    // MARK: - Helpers
    private func setupTableView() {
        self.tableView.tableFooterView = UIView()

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0 ))
        label.textAlignment = .center

        let nib = UINib(nibName: "Header", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "SectionHeader")

        tableView.backgroundView = label
        backgroundLabel = label
    }

    private func setupFetchController() {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let request = NSFetchRequest<Workout>(entityName: "Workout")
        request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: false)]
        request.propertiesToFetch = ["title", "workoutDescription", "created"]

        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext:context, sectionNameKeyPath: "sectionIdentifier", cacheName: nil)
        controller.delegate = self
        self.fetchedResultsController = controller
    }

    private func showEmptyElements() {
        backgroundLabel.text = NSLocalizedString("No Elements", comment: "Display not elements")
    }

    private func updateUI(firstTime: Bool = false) {
        do {
            try self.fetchedResultsController?.performFetch()
            tableView.reloadData()

            if let elements = fetchedResultsController?.fetchedObjects, elements.count == 0 {

                if firstTime {
                    downloadWorkout()
                } else {
                    showEmptyElements()
                }
            }

        } catch let error {
            print("Impossible to reload the content of the store: \(error)")
        }
    }

    private func workoutAt(indexPath: IndexPath) -> Workout? {
        return fetchedResultsController?.object(at: indexPath)
    }

    private func downloadWorkout() {

        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        let getWokoutOperation = DownloadWorkoutListProcedure(context: context, successBlock: {

            // Avoid glitch when download too fast
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.refreshControl?.endRefreshing()
                self.updateUI()
            }

        }) { (error) in
            print("Can not retrieve the data: \(error)")
             DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                self.refreshControl?.endRefreshing()
                self.showAlert()
            }
        }

        getWokoutOperation.add(condition: MutuallyExclusive<DownloadWorkoutListProcedure>())
        queue.addOperation(getWokoutOperation)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if let detailsVC = segue.destination as? DetailsVC, let selectedIndexPath = self.tableView.indexPathForSelectedRow {
            detailsVC.currentWorkout = workoutAt(indexPath: selectedIndexPath)
        }
    }

    private func showAlert() {
        let controller = UIAlertController(title: NSLocalizedString("An error occured.", comment: "Alert list title"), message: NSLocalizedString("Impossible to fetch the data. Please try again later", comment: "Alert list title"), preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(controller, animated: true)
    }
}

extension MasterVC: NSFetchedResultsControllerDelegate {

}
