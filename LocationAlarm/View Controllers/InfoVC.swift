//
//  InfoVC.swift
//  LocationAlarm
//
//  Created by Ahmed Osama on 9/3/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import UIKit

class InfoVC: UIViewController {

    @IBOutlet weak var appNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appNameLabel.text = "📍Location Alarm v" + version
        }
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
