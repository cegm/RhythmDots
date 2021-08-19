//
//  SettingsViewController.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 7/10/18.
//  Copyright © 2018 Eduardo Gil. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseUI

typealias FIRUser = FirebaseAuth.User

class SettingsViewController: UIViewController {
    
    var columnsNumber: Int = 5
    var rowsNumber: Int = 5
    var densityNumber: Int = 50
    var metronome: Bool = true
    var tempo: Double = 60
    var selectedColor1: Int = 0
    var selectedColor2: Int = 0
    
    @IBOutlet weak var columnsLabel: UILabel!
    @IBOutlet weak var columnsStepper: UIStepper!
    @IBOutlet weak var rowsLabel: UILabel!
    @IBOutlet weak var rowsStepper: UIStepper!
    @IBOutlet weak var densityLabel: UILabel!
    @IBOutlet weak var densityStepper: UIStepper!
    @IBOutlet weak var metronomeSwitch: UISwitch!
    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var tempoStepper: UIStepper!
    
    var dots: [UIImage] = [UIImage(named: "black")!, UIImage(named: "red")!, UIImage(named: "orange")!, UIImage(named: "yellow")!, UIImage(named: "green")!, UIImage(named: "blue")!, UIImage(named: "purple")!, UIImage(named: "blank")!]
    var dotsOff: [UIImage] = [UIImage(named: "blackOff")!, UIImage(named: "redOff")!, UIImage(named: "orangeOff")!, UIImage(named: "yellowOff")!, UIImage(named: "greenOff")!, UIImage(named: "blueOff")!, UIImage(named: "purpleOff")!]
    @IBOutlet weak var button10: UIButton!
    @IBOutlet weak var button11: UIButton!
    @IBOutlet weak var button12: UIButton!
    @IBOutlet weak var button13: UIButton!
    @IBOutlet weak var button14: UIButton!
    @IBOutlet weak var button15: UIButton!
    @IBOutlet weak var button16: UIButton!
    @IBOutlet weak var button20: UIButton!
    @IBOutlet weak var button21: UIButton!
    @IBOutlet weak var button22: UIButton!
    @IBOutlet weak var button23: UIButton!
    @IBOutlet weak var button24: UIButton!
    @IBOutlet weak var button25: UIButton!
    @IBOutlet weak var button26: UIButton!
    @IBOutlet weak var myProgramsButton: UIButton!
    
    var buttons1: [UIButton] = []
    var buttons2: [UIButton] = []
    
    var userData = UserData()
    
    var handle: AuthStateDidChangeListenerHandle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Settings for color buttons
        buttons1 = [button10, button11, button12, button13, button14, button15, button16]
        buttons2 = [button20, button21, button22, button23, button24, button25, button26]
        for button in buttons1 {
            button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        }
        for button in buttons2 {
            button.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        }
        
        changeMyPorgramsButtonStatus(enabled: false) // Only available if user is authenticated.
        
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if user == nil {
                // Load FirebaseUI to handle authentication.
                // 1. Access the FUIAuth default auth UI singleton.
                guard let authUI = FUIAuth.defaultAuthUI()
                else { return }

                // 2. Set the FUIAuth's singleton's delegate.
                authUI.delegate = self
                
                // 3. Set authentication methods providers.
                let providers: [FUIAuthProvider] = [
                  FUIGoogleAuth(),
                  FUIEmailAuth(),
                  //FUIFacebookAuth(),
                  //FUITwitterAuth(),
                  //FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()),
                ]
                authUI.providers = providers

                // 4. Present the auth view controller.
                let authViewController = authUI.authViewController()
                self.present(authViewController, animated: true)
                
                
                // 5. Implementation of the FUIAuthDelegate protocol is done after
                //  the closing curly brace of the LoginViewController class
            }
            else {
                self.changeMyPorgramsButtonStatus(enabled: true)  // Only available if user is authenticated.
                print("Sí entra al if")
                let user = Auth.auth().currentUser
                if let user = user {
                    let uid = user.uid
                    print(uid)
                    self.userData = UserData(uid: uid)
                    print("Sí tenía que cambiar esa madre")
                    self.getUserSettings(programNumber: 0)
                    self.applyUserSettings()
                }
            }
        }
        applyUserSettings()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        Auth.auth().removeStateDidChangeListener(handle!)
        do {
          try Auth.auth().signOut()
        } catch let err {
          print(err)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getUserSettings(programNumber: Int) {
        print(self.userData.uid)
        print(self.userData.userPrograms)
        self.columnsNumber = self.userData.userPrograms[programNumber]["columnsNumber"] as! Int
        self.rowsNumber = self.userData.userPrograms[programNumber]["rowsNumber"] as! Int
        self.densityNumber = self.userData.userPrograms[programNumber]["densityNumber"] as! Int
        self.metronome = self.userData.userPrograms[programNumber]["metronome"] as! Bool
        self.tempo = self.userData.userPrograms[programNumber]["tempo"] as! Double
        self.selectedColor1 = self.userData.userPrograms[programNumber]["selectedColor1"] as! Int
        self.selectedColor2 = self.userData.userPrograms[programNumber]["selectedColor2"] as! Int
    }
    
    func applyUserSettings() {
        // Default parameters
        setLabelAndStepper(label: columnsLabel, stepper: columnsStepper, value: columnsNumber)
        setLabelAndStepper(label: rowsLabel, stepper: rowsStepper, value: rowsNumber)
        setLabelAndStepper(label: densityLabel, stepper: densityStepper, value: densityNumber)
        
        metronomeSwitch.isOn = metronome
        bpmLabel.isEnabled = metronome
        tempoLabel.isEnabled = metronome
        tempoStepper.isEnabled = metronome
        
        var value: Double!
        if metronome {
            value = tempo
        }
        else {
            value = 60
        }
        
        setLabelAndStepper(label: tempoLabel, stepper: tempoStepper, value: Int(value))
        
        changeColor(colorNumber: 1, buttonNumber: selectedColor1)
        changeColor(colorNumber: 2, buttonNumber: selectedColor2)
    }
    
    func setLabelAndStepper(label: UILabel, stepper: UIStepper, value: Int) {
        label.text = String(value)
        stepper.value = Double(value)
    }
    
    @IBAction func changeColumns(_ sender: UIStepper) {
        columnsLabel.text = Int(sender.value).description
    }
    
    @IBAction func changeRows(_ sender: UIStepper) {
        rowsLabel.text = Int(sender.value).description
    }
    
    @IBAction func changeDensity(_ sender: UIStepper) {
        densityLabel.text = Int(sender.value).description
    }
    
    @IBAction func changeTempo(_ sender: UIStepper) {
        tempoLabel.text = Int(sender.value).description
    }
    
    @IBAction func metronome(_ sender: UISwitch) {
        if metronomeSwitch.isOn {
            bpmLabel.isEnabled = true
            tempoLabel.isEnabled = true
            tempoStepper.isEnabled = true
        }
        else {
            bpmLabel.isEnabled = false
            tempoLabel.isEnabled = false
            tempoStepper.isEnabled = false
        }
    }
    
    @IBAction func changeColor10(_ sender: UIButton) {
        changeColor(colorNumber: 1, buttonNumber: 0)
    }
    
    @IBAction func changeColor11(_ sender: UIButton) {
        changeColor(colorNumber: 1, buttonNumber: 1)
    }
    
    @IBAction func changeColor12(_ sender: UIButton) {
        changeColor(colorNumber: 1, buttonNumber: 2)
    }
    
    @IBAction func changeColor13(_ sender: UIButton) {
        changeColor(colorNumber: 1, buttonNumber: 3)
    }
    
    @IBAction func changeColor14(_ sender: UIButton) {
        changeColor(colorNumber: 1, buttonNumber: 4)
    }
    
    @IBAction func changeColor15(_ sender: UIButton) {
        changeColor(colorNumber: 1, buttonNumber: 5)
    }
    
    @IBAction func changeColor16(_ sender: UIButton) {
        changeColor(colorNumber: 1, buttonNumber: 6)
    }
    
    @IBAction func changeColor20(_ sender: UIButton) {
        changeColor(colorNumber: 2, buttonNumber: 0)
    }
    
    @IBAction func changeColor21(_ sender: UIButton) {
        changeColor(colorNumber: 2, buttonNumber: 1)
    }
    
    @IBAction func changeColor22(_ sender: UIButton) {
        changeColor(colorNumber: 2, buttonNumber: 2)
    }
    
    @IBAction func changeColor23(_ sender: UIButton) {
        changeColor(colorNumber: 2, buttonNumber: 3)
    }
    
    @IBAction func changeColor24(_ sender: UIButton) {
        changeColor(colorNumber: 2, buttonNumber: 4)
    }
    
    @IBAction func changeColor25(_ sender: UIButton) {
        changeColor(colorNumber: 2, buttonNumber: 5)
    }
    
    @IBAction func changeColor26(_ sender: UIButton) {
        changeColor(colorNumber: 2, buttonNumber: 6)
    }
    
    func changeColor(colorNumber: Int, buttonNumber: Int) {
        if colorNumber == 1 {
            buttons1[buttonNumber].setImage(dots[buttonNumber], for: .normal)
            buttons1[selectedColor1].setImage(dotsOff[selectedColor1], for: .normal)
            selectedColor1 = buttonNumber
        }
        else {
            buttons2[buttonNumber].setImage(dots[buttonNumber], for: .normal)
            buttons2[selectedColor2].setImage(dotsOff[selectedColor2], for: .normal)
            selectedColor2 = buttonNumber
        }
    }
    
    // Hide or show myProgramsButton according to Bool parameter enabled.
    func changeMyPorgramsButtonStatus(enabled: Bool) {
        myProgramsButton.isEnabled = enabled
        myProgramsButton.isHidden = !enabled
    }
    
    @IBAction func displayMyPrograms(_ sender: UIButton) {
        
        let user = Auth.auth().currentUser
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            //let dataPicker = DataPicker(uid: uid)
            //dataPicker.myFunction()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is GameViewController
        {
            let vc = segue.destination as? GameViewController
            vc?.columnsNumber = Int(columnsLabel.text!)!
            vc?.rowsNumber = Int(rowsLabel.text!)!
            vc?.densityNumber = Int(densityLabel.text!)!
            vc?.metronome = metronomeSwitch.isOn
            vc?.tempo = Double(tempoLabel.text!)!
            vc?.color1 = selectedColor1
            vc?.color2 = selectedColor2
            vc?.master = true
        }
        
    }
    

    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    

}

// Conform the SettingsViewController to the FUIAuthDelegate protocol.
extension SettingsViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        // Error handling during authentication.
        if let error = error {
            //assertionFailure("Error signing in: \(error.localizedDescription)")
            
            print(error)
            // Hide myProgramsButton
            changeMyPorgramsButtonStatus(enabled: false)
            
            return
        }

        print("handle user signup / login")
    }
}
