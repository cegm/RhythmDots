//
//  DataPicker.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 18/08/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import UIKit
import Foundation
import FirebaseFirestore

protocol DataPickerDelegate: NSObject {
    func didClickToolbarButton(selectedRowIndex: Int, overwrite: Bool)
}

class DataPicker: NSObject, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    // Variables necesarias para el picker
    var done: UIAlertAction!
    
    var iPhone: Bool!
    var landscape: Bool!
    var picker: UIPickerView!
    var dataArray: [String]!
    var blurEffectView: UIVisualEffectView!
    var toolBar: UIToolbar!
    var pickerStackView: UIStackView!
    
    var centerXAnchor: NSLayoutXAxisAnchor!
    var centerYAnchor: NSLayoutYAxisAnchor!
    var bottomAnchor: NSLayoutYAxisAnchor!
    var heightAnchor: NSLayoutDimension!
    var widthAnchor: NSLayoutDimension!
    
    var blurEffectViewWidthConstraintLandscape: NSLayoutConstraint!
    var blurEffectViewHeightConstraintLandscape: NSLayoutConstraint!
    var blurEffectViewWidthConstraintPortrait: NSLayoutConstraint!
    var blurEffectViewHeightConstraintPortrait: NSLayoutConstraint!
    
    var pickerStackViewWidthConstraintLandscape: NSLayoutConstraint!
    var pickerStackViewHeightConstraintLandscape: NSLayoutConstraint!
    var pickerStackViewWidthConstraintPortrait: NSLayoutConstraint!
    var pickerStackViewHeightConstraintPortrait: NSLayoutConstraint!
    
    weak var delegate:DataPickerDelegate!
    
    
    init(dataArray: [String], centerXAnchor: NSLayoutXAxisAnchor, centerYAnchor: NSLayoutYAxisAnchor, bottomAnchor: NSLayoutYAxisAnchor, heightAnchor: NSLayoutDimension, widthAnchor: NSLayoutDimension) {
        super.init()  // call this so that you can use self below
        self.dataArray = dataArray
        if self.dataArray.count < 5 {
            self.dataArray.append("New entry...")
        }
        
        self.landscape = UIApplication.shared.statusBarOrientation.isLandscape
        self.iPhone = UIDevice.current.userInterfaceIdiom == .phone
        self.centerXAnchor = centerXAnchor
        self.centerYAnchor = centerYAnchor
        self.bottomAnchor = bottomAnchor
        self.heightAnchor = heightAnchor
        self.widthAnchor = widthAnchor
        
        self.createPicker()
        
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    @objc func deviceRotated(){
        print("rotó")
        if !self.isHidden() {
            if blurEffectViewWidthConstraintLandscape != nil {
                activateConstraints()
            }
            //constraints()
        }
    }
    
    func createPicker() {
           setBlurryEffect()
           setPicker()
           setToolbar()
           setPickerStackView(array: [toolBar, picker])
           //activateConstraints()
    }
    
    /*
    func isiPhone(landscape: Bool) -> Bool {
        if landscape {
            return UIScreen.main.bounds.size.height < 415
        }
        else {
            return UIScreen.main.bounds.size.width < 415
        }
    }
    */
    
    func isiPadPro(landscape: Bool) -> Bool {
        if landscape {
            return UIScreen.main.bounds.size.height > 1500
        }
        else {
            return UIScreen.main.bounds.size.width > 1500
        }
    }
    
    
    
    func setBlurryEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        //blurEffectView.frame = self.view.frame
        //self.view.addSubview(blurEffectView)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        blurEffectView.backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.55)
           
        blurEffectView.layer.shadowColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1).cgColor
        blurEffectView.layer.shadowOpacity = 0.3
        blurEffectView.layer.shadowOffset = .zero
        blurEffectView.layer.shadowRadius = 4
    }
    
    
    
    func setPickerStackView(array: [UIView]) {
        pickerStackView = UIStackView(arrangedSubviews: array)
        pickerStackView.axis = .vertical
        pickerStackView.distribution = .fill
        pickerStackView.alignment = .fill
        pickerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        //self.view.addSubview(pickerStackView) ---------------_> MMMMMMUy importante
    }
    
    func constraints() {
        self.setBlurEffectViewConstraints()
        self.setPickerStackViewConstraints()
        self.activateConstraints()
    }
    
    func setBlurEffectViewConstraints() {
        let constraints = getConstraints(view: blurEffectView)
        
        blurEffectViewWidthConstraintLandscape = constraints[0]
        blurEffectViewHeightConstraintLandscape = constraints[1]
        blurEffectViewWidthConstraintPortrait = constraints[2]
        blurEffectViewHeightConstraintPortrait = constraints[3]
        blurEffectView.layer.cornerRadius = 20.0
        blurEffectView.clipsToBounds = true
    }
    
    func setPickerStackViewConstraints() {
        let constraints = getConstraints(view: self.pickerStackView)
        
        self.pickerStackViewWidthConstraintLandscape = constraints[0]
        self.pickerStackViewHeightConstraintLandscape = constraints[1]
        self.pickerStackViewWidthConstraintPortrait = constraints[2]
        self.pickerStackViewHeightConstraintPortrait = constraints[3]
        self.pickerStackView.layer.cornerRadius = 20.0
        self.pickerStackView.clipsToBounds = true
    }
    
    
    func getConstraints(view: UIView) -> [NSLayoutConstraint] {
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        if iPhone {
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
            //view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        else {
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        
        self.landscape = UIApplication.shared.statusBarOrientation.isLandscape
        return getSizeConstraints(view: view, landscape: self.landscape)
    }
    
    func getSizeConstraints(view: UIView, landscape: Bool) -> [NSLayoutConstraint] {
        //let widthConstant: CGFloat
        //let heightConstant: CGFloat
        
        let widthLandscapeMultiplier: CGFloat
        let heightLandscapeMultiplier: CGFloat
        let widthPortraitMultiplier: CGFloat
        let heightPortraitMultiplier: CGFloat
        
        if iPhone {
            widthLandscapeMultiplier = 1
            heightLandscapeMultiplier = 0.55
            widthPortraitMultiplier = 1
            heightPortraitMultiplier = 0.4
            
            /*if landscape {
                widthConstant = 0
                heightConstant = -170
            } else
            {
                widthConstant = 0
                heightConstant = -400
            }*/
        }
        else {
            /*if landscape {
                widthConstant = 0
                heightConstant = -170
            } else
            {
                widthConstant = 0
                heightConstant = -400//-400
            }*/
            widthLandscapeMultiplier = 0.7
            heightLandscapeMultiplier = 0.32
            widthPortraitMultiplier = 0.85
            heightPortraitMultiplier = 0.25
        }
        //let widthLandscape = view.widthAnchor.constraint(equalTo: self.heightAnchor, constant: widthConstant)
        //let heightLandscape = view.heightAnchor.constraint(equalTo: self.widthAnchor, constant: heightConstant)
        //let widthPortrait = view.widthAnchor.constraint(equalTo: self.widthAnchor, constant: widthConstant)
        //let heightPortrait = view.heightAnchor.constraint(equalTo: self.heightAnchor, constant: heightConstant)
        
        let widthLandscape = view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: widthLandscapeMultiplier)
        let heightLandscape = view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: heightLandscapeMultiplier)
        let widthPortrait = view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: widthPortraitMultiplier)
        let heightPortrait = view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: heightPortraitMultiplier)
        
        return [widthLandscape, heightLandscape, widthPortrait, heightPortrait]
    }
    
    func activateConstraints() {
        if UIDevice.current.orientation.isLandscape {
            blurEffectViewWidthConstraintPortrait.isActive = false
            blurEffectViewHeightConstraintPortrait.isActive = false
            blurEffectViewWidthConstraintLandscape.isActive = true
            blurEffectViewHeightConstraintLandscape.isActive = true
            
            pickerStackViewWidthConstraintPortrait.isActive = false
            pickerStackViewHeightConstraintPortrait.isActive = false
            pickerStackViewWidthConstraintLandscape.isActive = true
            pickerStackViewHeightConstraintLandscape.isActive = true
        }
        else {
            blurEffectViewWidthConstraintLandscape.isActive = false
            blurEffectViewHeightConstraintLandscape.isActive = false
            blurEffectViewWidthConstraintPortrait.isActive = true
            blurEffectViewHeightConstraintPortrait.isActive = true
            
            pickerStackViewWidthConstraintLandscape.isActive = false
            pickerStackViewHeightConstraintLandscape.isActive = false
            pickerStackViewWidthConstraintPortrait.isActive = true
            pickerStackViewHeightConstraintPortrait.isActive = true
        }
    }
    
    func setPicker() {
        picker = UIPickerView()
        picker.delegate = self as UIPickerViewDelegate
        picker.dataSource = self as UIPickerViewDataSource
    }
    
    func setToolbar() {
        toolBar = UIToolbar(frame:CGRect(x:0, y:0, width:100, height:100))
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor(red: 92/255, green: 216/255, blue: 255/255, alpha: 1)
        //toolBar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        toolBar.sizeToFit()
           
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
           doneButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let middleButton = UIBarButtonItem(title: "Overwrite", style: .plain, target: self, action: #selector(overwriteClick))
        middleButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        let rightSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        cancelButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        toolBar.setItems([cancelButton, leftSpace, middleButton, rightSpace, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
           
        /*let path = UIBezierPath(roundedRect: toolBar.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 20, height: 20))
        let maskLayer = CAShapeLayer()
        maskLayer.frame = toolBar.bounds
        maskLayer.path = path.cgPath
        toolBar.layer.mask = maskLayer*/
        toolBar.layer.cornerRadius = 20.0
        toolBar.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            toolBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        else {
            // Fallback on earlier versions
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataArray.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let row = dataArray[row]
        return row
    }
    
    @objc func doneClick() {
        let selectedRowIndex = picker.selectedRow(inComponent: 0)
        hidePicker(animation: true)
        delegate.didClickToolbarButton(selectedRowIndex: selectedRowIndex, overwrite: false)
    }
    
    @objc func overwriteClick() {
        let selectedRowIndex = picker.selectedRow(inComponent: 0)
        hidePicker(animation: true)
        delegate.didClickToolbarButton(selectedRowIndex: selectedRowIndex, overwrite: true)
    }
    
    @objc func cancelClick() {
        hidePicker(animation: true)
    }
    func showPicker(animation: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.blurEffectView.alpha = 1
            self.picker.alpha = 1
            self.toolBar.alpha = 1
        }
        picker.isUserInteractionEnabled = true
        toolBar.isUserInteractionEnabled = true
    }
    
    func hidePicker(animation: Bool) {
        let time: Double
        if animation {
            time = 0.3
        }
        else {
            time = 0
        }
        UIView.animate(withDuration: time) {
            self.blurEffectView.alpha = 0
            self.picker.alpha = 0
            self.toolBar.alpha = 0
        }
        picker.isUserInteractionEnabled = false
        toolBar.isUserInteractionEnabled = false
        
        blurEffectView.removeFromSuperview()
        pickerStackView.removeFromSuperview()
    }
    
    func isHidden() -> Bool {
        return self.blurEffectView.alpha == 0 && self.picker.alpha == 0 && self.toolBar.alpha == 0
    }
    
    /*
    func presentAlert(message: String, newEntry: Bool) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .default) { [unowned alert] _ in
           }
        alert.addAction(cancel)
        if newEntry {
            alert.addTextField { (textField) in
                textField.placeholder = "Name"
            }
            self.done = UIAlertAction(title: "Done", style: .default) { [unowned alert] _ in
                let name = alert.textFields![0].text
                //print(self.score)
                // do something interesting with "answer" here
            }
            alert.addAction(self.done)
        }
        else {
            self.done = UIAlertAction(title: "Done", style: .default) { [unowned alert] _ in
                self.showPicker(animation: true)
                // do something interesting with "answer" here
            }
            alert.addAction(self.done)
        }
        present(alert, animated: true)
    }
    */
    
    /*
    func register() {
        let date = Date()
        let dateFormatter:DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        let timeStamp:String = dateFormatter.string(from: date)
           
        //let user = Auth.auth().currentUser!.email!.components(separatedBy: "@")[0].replacingOccurrences(of: ".", with: "")
        let userid = Auth.auth().currentUser!.uid
           
        self.ref.child(userid).setValue(timeStamp)
           
        if metronome {
            self.ref.child(userid).child(timeStamp).setValue(["rowsNumber":rowsNumber, "columnsNumber":columnsNumber, "densityNumber":densityNumber, "tempo": tempo, "color1": colors[color1], "color2": colors[color2]])
        }
        else {
            self.ref.child(userid).child(timeStamp).setValue(["rowsNumber":rowsNumber, "columnsNumber":columnsNumber, "densityNumber":densityNumber, "color1": colors[color1], "color2": colors[color2]])
        }
    }
    */
}
