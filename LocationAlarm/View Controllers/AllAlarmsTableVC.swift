//
//  ViewController.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/12/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit
import CoreData

class AllAlarmsTableVC: UIViewController {
    
    // MARK: - Declarations
    
    var dataController: DataController!
    var locationManager: LocationManager!
    var frc: NSFetchedResultsController<Alarm>!
    var selectedAlarm: Alarm!
    let alarmSettingsSegueId = "showAlarm"
    let infoSegueId = "showInfo"
    let cacheName = "alarms"
    
    // MARK: - IBOutlets
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var noAlarms: UILabel!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        locationManager = (UIApplication.shared.delegate as! AppDelegate).locationManager
        //tableView.delegate = self
        //tableView.dataSource = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupFetchedResultsController()
        tableView.reloadData()
        hideTableIfEmpty()
        addInfoButton()
        selectedAlarm = nil
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        frc = nil
        NSFetchedResultsController<Alarm>.deleteCache(withName: cacheName)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == alarmSettingsSegueId {
            let vc = segue.destination as! AlarmSettingsVC
            vc.alarm = selectedAlarm
        }
    }

}


// MARK: - Customized

extension AllAlarmsTableVC {
    
    // MARK: - Editing
    
    func deleteAlarm(at indexPath: IndexPath) {
        let alarm = frc.object(at: indexPath)
        locationManager.stopMonitoringAlarm(alarm: alarm)
        dataController.viewContext.delete(alarm)
        try? dataController.viewContext.save()
    }
    
    // MARK: - Helpers
    
    func setupFetchedResultsController() {
        let sortKey = "id"
        dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
        let request: NSFetchRequest<Alarm> = Alarm.fetchRequest()
        let sort = NSSortDescriptor(key: sortKey, ascending: true)
        request.sortDescriptors = [sort]
        frc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: cacheName)
        frc.delegate = self
        do {
            try frc.performFetch()
        }
        catch {
            fatalError("Error fetching data: " + error.localizedDescription)
        }
    }
    
    func hideTableIfEmpty() {
        if frc.sections?[0].numberOfObjects == 0 {
            noAlarms.isHidden = false
            tableView.isHidden = true
        }
        else {
            noAlarms.isHidden = true
            tableView.isHidden = false
        }
    }
    
    func addInfoButton() {
        let infoButton = UIButton(type: .infoLight)
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        let barButton = UIBarButtonItem(customView: infoButton)
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    @objc func infoButtonTapped() {
        performSegue(withIdentifier: infoSegueId, sender: self)
    }
    
}

// MARK: - TableView and DataSource Delegates

extension AllAlarmsTableVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if frc.sections != nil {
            return frc.sections!.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (frc.sections?[section].numberOfObjects)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let alarm = frc.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: TableCell.defaultReuseIdentifier, for: indexPath) as! TableCell
        
        // Configure cell
        cell.alarmName.text = alarm.name
        cell.alarmDetails.text = alarm.details
        cell.alarmSwitch.isOn = alarm.isEnabled
        cell.alarm = alarm
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedAlarm = frc.object(at: indexPath)
        performSegue(withIdentifier: alarmSettingsSegueId, sender: self)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteAlarm(at: indexPath)
        }
    }
    
}

// MARK: - FRC Delegate

extension AllAlarmsTableVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        hideTableIfEmpty()
    }
    
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }
    
}

