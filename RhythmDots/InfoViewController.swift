//
//  InfoViewController.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 24/09/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import Foundation
import UIKit
import FirebaseAuth

//typealias FIRUser = FirebaseAuth.User

class InfoViewController: UIViewController {
    
    @IBOutlet weak var logoutButton: UIButton!
    var handle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            let enabled = user != nil
            self.changeLogoutButtonStatus(enabled: enabled)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Hide or show logoutButton according to Bool parameter enabled.
    func changeLogoutButtonStatus(enabled: Bool) {
        logoutButton.isEnabled = enabled
        logoutButton.isHidden = !enabled
    }
    
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch let err {
            print(err)
        }
    }
}
