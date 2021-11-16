//
//  PairingViewController.swift
//  RhythmDots
//
//  Created by Carlos Eduardo Gil Mezta on 13/11/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import UIKit

class PairingViewController: UIViewController, SessionHandlerDelegate {
    var columnsNumber: Int = 5
    var rowsNumber: Int = 5
    var densityNumber: Int = 50
    var metronome: Bool = true
    var tempo: Double = 60
    var color1: Int = 0
    var color2: Int = 0
    var role: String = "Solo"
    
    var sessionHandler: SessionHandler!
    
    @IBOutlet weak var shareLabel: UILabel!
    @IBOutlet weak var sessionCodeLabel: UILabel!
    
    override func viewDidLoad() {
        if self.role == "Host" {
            self.sessionCodeLabel.text = self.sessionHandler.sessionCode
            self.sessionHandler.delegate = self
            self.sessionHandler.waitForGuestToJoin()
        }
        else {
            shareLabel.isHidden = true
            sessionCodeLabel.isHidden = true
            
            self.sessionHandler = SessionHandler()
            self.sessionHandler.delegate = self
            
            let message: String = "Enter code to join a session."
            presentAlert(message: message, firstAttempt: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if self.role == "Guest" {
            let message: String = "Enter code to join a session."
            presentAlert(message: message, firstAttempt: true)
        }
        if self.sessionHandler != nil {
            print("viewWillAppear")
            self.sessionHandler.delegate = self
            self.sessionHandler.changeGameStatus(status: "Pairing")
        }
        /*else {
            self.sessionHandler.delegate = self
            self.sessionHandler.changeGameStatus(status: "Pairing")
        }*/
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if self.role == "Guest" {
            /*
            if self.isMovingFromParent {
                self.sessionHandler.changeGuestStatus(guestIsActive: false)
                self.sessionHandler.terminateSession()
            }*/
        }
    }
    

    
    func presentAlert(message: String, firstAttempt: Bool) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default)  { [unowned alert] _ in
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(cancel)
        
        
        alert.addTextField { (textField) in
            textField.placeholder = "Code"
        }
        
        let done = UIAlertAction(title: "Done", style: .default) { [unowned alert] _ in
            let sessionCode = alert.textFields![0].text
            
            self.sessionHandler.joinSession(sessionCode: sessionCode ?? "-")  { (success, error) in
                if let error = error {
                    print("PairingViewController.swift: Error joining session: \(error)")
                }
                if success != nil {
                    if success! {
                        self.performSegue(withIdentifier: "fromPairingToGame", sender: self)
                    }
                    else {
                        let message = "Sorry, that code didn't work. Please try again."
                        self.presentAlert(message: message, firstAttempt: false)
                    }
                }
                /*
                if success != nil && parameters != nil {
                    if success! {
                        self.columnsNumber = parameters!["columnsNumber"] as? Int ?? 5
                        self.rowsNumber = parameters!["rowsNumber"] as? Int ?? 5
                        self.densityNumber = parameters!["densityNumber"] as? Int ?? 50
                        self.metronome = parameters!["metronome"] as? Bool ?? true
                        self.tempo = parameters!["tempo"] as? Double ?? 60
                        self.color1 = parameters!["color1"] as? Int ?? 0
                        self.color2 = parameters!["color2"] as? Int ?? 0
                        
                        self.performSegue(withIdentifier: "fromPairingToGame", sender: self)
                        print("success")
                    }
                    else {
                        let message = "Sorry, that code didn't work. Please try again."
                        self.presentAlert(message: message, firstAttempt: false)
                    }
                }*/
            }
        }
        alert.addAction(done)
        present(alert, animated: true)
    }
    
    func sessionStatusChanged(message: String) {
        if self.role == "Host" {
            if message == "Guest joined" {
                self.performSegue(withIdentifier: "fromPairingToGame", sender: self)
            }
            else {
                print(message)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameViewController
        {
            let vc = segue.destination as? GameViewController
            vc?.columnsNumber = self.columnsNumber
            vc?.rowsNumber = self.rowsNumber
            vc?.densityNumber = self.densityNumber
            vc?.metronome = self.metronome
            vc?.tempo = self.tempo
            vc?.color1 = self.color1
            vc?.color2 = self.color2
            vc?.role = self.role
            vc?.sessionHandler = self.sessionHandler
        }
    }
}
