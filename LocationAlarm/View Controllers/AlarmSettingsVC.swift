//
//  AlarmSettingsVC.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/24/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class AlarmSettingsVC: UIViewController, AlarmSettingsTableVCDelegate {
    
    // MARK: - Declarations
    
    let tableVCSegueId = "showTable"
    
    // At AppDelegate
    var dataController: DataController!
    var locationManager: LocationManager!
    
    // Class delegate
    weak var delegate: AlarmSettingsVCDelegate?
    
    // Injected
    var alarm: Alarm!
    
    // Outlets
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        locationManager = appDelegate.locationManager
        dataController = appDelegate.dataController
        
        setupViewProperties()
    }
    
    // MARK: - Actions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        delegate?.saveButtonTapped()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        showDeleteAlarmAlert()
    }
    
    // MARK: - Helpers
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == tableVCSegueId {
            let vc = segue.destination as! AlarmSettingsTableVC
            vc.view.translatesAutoresizingMaskIntoConstraints = false
            vc.alarm = alarm
            vc.delegate = self
            self.delegate = vc
        }
    }
    
    fileprivate func setupViewProperties() {
        if alarm == nil {
            navigationItem.title = "Add Alarm"
            saveButton.isEnabled = false
            deleteButton.isHidden = true
        }
        else {
            navigationItem.title = "Edit Alarm"
        }
    }
    
    func showDeleteAlarmAlert() {
        let alert = UIAlertController(title: "Delete Alarm", message: "Are you sure you want to delete this alarm?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.deleteThisAlarm()
            self.navigationController?.popViewController(animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteThisAlarm() {
        locationManager.stopMonitoringAlarm(alarm: alarm)
        dataController.viewContext.delete(alarm)
        try? dataController.viewContext.save()
    }
    
    // MARK: - Protocols Implementations
    
    func okToSave() {
        saveButton.isEnabled = true
    }
    
}

// MARK: - Class Delegate Protocol

protocol AlarmSettingsVCDelegate: AnyObject {
    func saveButtonTapped()
}

