//
//  AlarmVC.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 8/13/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import AVFoundation
import MapKit

class AlarmSettingsTableVC: UITableViewController {
    
    // MARK: - Declarations
    
    var firstTimeToLoad: Bool = true
    let mapVCSegueId = "showMap"
    
    var alarmLabel: String!
    var latitude: Double!
    var longitude: Double!
    var distance: Double!
    var sound: Sound!
    
    // From AppDelegate
    var dataController: DataController!
    var locationManager: LocationManager!
    var audioPlayer: AudioPlayer?
    
    // Injected
    var alarm: Alarm!
    
    // Class delegate
    weak var delegate: AlarmSettingsTableVCDelegate?
    
    // IBOutlets
    @IBOutlet weak var labelUILabel: UILabel!
    @IBOutlet weak var locationUILabel: UILabel!
    @IBOutlet weak var soundUILabel: UILabel!
    
    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var repeatSwitch: UISwitch!
    
    @IBOutlet weak var repeatTableViewCell: UITableViewCell!
    
    // Enums
    enum AlarmProperty: Int {
        case label, location, sound
    }
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        locationManager = appDelegate.locationManager
        audioPlayer = appDelegate.audioPlayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstTimeToLoad {
            fetchValuesFromModel() //can't be at viewDidLoad(), as alarm wouldn't be inject by parent yet
            pushValuesToView()
            firstTimeToLoad = false
        }
        setupTableHeight()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == mapVCSegueId {
            let vc = segue.destination as! MapVC
            vc.latitude = latitude
            vc.longitude = longitude
            vc.distance = distance
            vc.onSave = { [] in
                self.latitude = vc.latitude
                self.longitude = vc.longitude
                self.distance = vc.distance
                let coordinate = CLLocationCoordinate2DMake(self.latitude, self.longitude)
                self.locationUILabel.text = LocationManager.getLameDescription(for: coordinate)
                LocationManager.getDescription(for: coordinate, completionHandler: { (description) -> () in
                    self.locationUILabel.text = description
                })
                self.delegate?.okToSave()
            }
        }
    }
    
    // MARK: - TableView
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let value = AlarmProperty.init(rawValue: indexPath.row) {
            switch value {
            case .label:
                showAlarmLabelAlert()
                break
            case .location:
                performSegue(withIdentifier: mapVCSegueId, sender: self)
                break
            case .sound:
                showSoundPickerInAlert()
                break
            }
        }
    }
    
    // MARK: - Editing
    
    func createAlarm() {
        alarm = Alarm(context: dataController.viewContext)
        alarm.id = dataController.getAvailableId()
    }
    
    // MARK: - Actions
    
    @IBAction func vibrateSwitchValueChanged(_ sender: Any) {
        //
    }
    
    @IBAction func repeatSwitchValueChanged(_ sender: Any) {
        let toast = BlurryToast(frame: repeatTableViewCell.bounds)
        repeatTableViewCell.addSubview(toast)
        if repeatSwitch.isOn {
            toast.message = "Alarm will stay active after ringing"
        }
        else {
            toast.message = "Alarm will ring only one time"
        }
        repeatTableViewCell.isUserInteractionEnabled = false
        toast.showThenHide(completion: {
            self.repeatTableViewCell.isUserInteractionEnabled = true
        })
    }
    
    // MARK: - Helpers
    
    func setupTableHeight() {
        let rowHeight = 55
        let numberOfRows = 5
        let height = CGFloat(rowHeight * numberOfRows) //tableView.contentSize.height
        let tableViewHeight = NSLayoutConstraint(item: self.tableView, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height)
        tableView.addConstraint(tableViewHeight)
    }
    
    func fetchValuesFromModel() {
        if alarm == nil {
            alarmLabel = "New Alarm"
            sound = .two
        }
        else {
            alarmLabel = alarm.name
            latitude = alarm.latitude
            longitude = alarm.longitude
            distance = alarm.distance
            sound = Sound(rawValue: alarm.sound!)
        }
    }
    
    func pushValuesToModel() {
        alarm.name = alarmLabel
        alarm.latitude = latitude
        alarm.longitude = longitude
        alarm.distance = distance
        alarm.details = locationUILabel.text
        alarm.sound = sound.rawValue
        alarm.stayActive = repeatSwitch.isOn
    }
    
    func pushValuesToView() {
        labelUILabel.text = alarmLabel
        if latitude != nil && longitude != nil {
            locationUILabel.text = alarm.details
            repeatSwitch.isOn = alarm.stayActive
        }
        else {
            locationUILabel.text = "No Location"
        }
        soundUILabel.text = sound.toFriendlyString()
    }
    
    func showAlarmLabelAlert() {
        let alert = UIAlertController(title: "Alarm Label", message: "", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = self.alarmLabel
            textField.placeholder = "Alarm Label"
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            self.alarmLabel = textField?.text
            self.labelUILabel.text = textField?.text
            if let indexPath = self.tableView.indexPathForSelectedRow {
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showSoundPickerInAlert() {
        let alert = UIAlertController(title: "Select Alarm Sound", message: "", preferredStyle: .actionSheet)
        
        // TODO: find an alternative for hard coded values
        let height = CGFloat(100)
        let frame = CGRect(x: -15, y: 30, width: alert.view.frame.width , height: height)
        
        let picker = UIPickerView(frame: frame)
        picker.delegate = self
        picker.dataSource = self
        picker.showsSelectionIndicator = true
        picker.selectRow(sound.toInt(), inComponent: 0, animated: false)
        
        let alertHeight = NSLayoutConstraint(item: alert.view, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height + 130)
        
        alert.view.addConstraint(alertHeight)
        alert.view.addSubview(picker)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.audioPlayer?.stop()
            let row = picker.selectedRow(inComponent: 0)
            self.sound = Sound.fromInt(value: row)
            self.soundUILabel.text = self.sound.toFriendlyString()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.audioPlayer?.stop()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK : - UIPickerView Delegate

extension AlarmSettingsTableVC: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Sound.fromInt(value: row).toFriendlyString()
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let sound = Sound.fromInt(value: row)
        audioPlayer?.play(sound: sound)
    }
    
}

// MARK: - AlarmSettingsVCDelegate Implementation

extension AlarmSettingsTableVC: AlarmSettingsVCDelegate {
    func saveButtonTapped() {
        if alarm == nil {
            createAlarm()
        }
        pushValuesToModel()
        try? dataController.viewContext.save()
        if alarm.isEnabled {
            locationManager.startMonitoringAlarm(alarm: alarm) //if enabled
        }
        navigationController?.popViewController(animated: true)
    }
}

// MARK: - Class Delegate Protocol

protocol AlarmSettingsTableVCDelegate: AnyObject {
    func okToSave()
}
