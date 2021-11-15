//
//  ViewController.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 7/9/18.
//  Copyright © 2018 Eduardo Gil. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var role: String = "Solo"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func playSolo(_ sender: UIButton) {
        self.role = "Solo"
        performSegue(withIdentifier: "fromWelcomeToSettings", sender: self)
    }
    @IBAction func hostSession(_ sender: UIButton) {
        self.role = "Host"
        performSegue(withIdentifier: "fromWelcomeToSettings", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is SettingsViewController {
            let viewController = segue.destination as? SettingsViewController
            viewController?.role = self.role
        }
        else {
            let viewController = segue.destination as? PairingViewController
            viewController?.role = "Guest"
        }
    }
}

