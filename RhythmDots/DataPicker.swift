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
    var numUserPrograms: Int!
    let maxNumUserPrograms = 5
    
    var iPhone: Bool!
    var landscape: Bool!
    var picker: UIPickerView!
    var dataArray: [String]!
    var shadowView: UIView!
    var blurEffectView: UIVisualEffectView!
    var toolBar: UIToolbar!
    var pickerStackView: UIStackView!
    
    var centerXAnchor: NSLayoutXAxisAnchor!
    var centerYAnchor: NSLayoutYAxisAnchor!
    var bottomAnchor: NSLayoutYAxisAnchor!
    var heightAnchor: NSLayoutDimension!
    var widthAnchor: NSLayoutDimension!
    
    var shadowViewWidthConstraintLandscape: NSLayoutConstraint!
    var shadowViewHeightConstraintLandscape: NSLayoutConstraint!
    var shadowViewWidthConstraintPortrait: NSLayoutConstraint!
    var shadowViewHeightConstraintPortrait: NSLayoutConstraint!
    
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
        self.numUserPrograms = self.dataArray.count
        if self.numUserPrograms < self.maxNumUserPrograms {
            self.dataArray.append("Save current settings...")
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
        if !self.isHidden() {
            if blurEffectViewWidthConstraintLandscape != nil {
                activateConstraints()
            }
        }
    }
    
    func createPicker() {
        setShadowView()
        setBlurryEffect()
        setPicker()
        setToolbar()
        setPickerStackView(array: [toolBar, picker])
           //activateConstraints()
    }
    
    func setShadowView() {
        shadowView = UIView()
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
    }
    
    
    func setBlurryEffect() {
        let blurEffect = UIBlurEffect(style: .light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 13.0, *) {
            blurEffectView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.4)
        } else {
            // Fallback on earlier versions
            blurEffectView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.55)
        }
           
        blurEffectView.layer.shadowColor = UIColor(red: 0.20, green: 0.20, blue: 0.20, alpha: 1).cgColor
        blurEffectView.layer.shadowOpacity = 0.3
        blurEffectView.layer.shadowOffset = .zero
        blurEffectView.layer.shadowRadius = 4
    }
    
    
    
    func setPickerStackView(array: [UIView]) {
        pickerStackView = UIStackView(arrangedSubviews: array)
        pickerStackView.axis = .vertical
        pickerStackView.distribution = .fillProportionally
        pickerStackView.alignment = .fill
        pickerStackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func constraints() {
        self.setShadowViewConstraints()
        self.setBlurEffectViewConstraints()
        self.setPickerStackViewConstraints()
        self.activateConstraints()
    }
    
    func setShadowViewConstraints() {
        let constraints = getConstraints(view: shadowView, center: true)
        
        shadowViewWidthConstraintLandscape = constraints[0]
        shadowViewHeightConstraintLandscape = constraints[1]
        shadowViewWidthConstraintPortrait = constraints[2]
        shadowViewHeightConstraintPortrait = constraints[3]
    }
    
    func setBlurEffectViewConstraints() {
        let constraints = getConstraints(view: blurEffectView)
        
        blurEffectViewWidthConstraintLandscape = constraints[0]
        blurEffectViewHeightConstraintLandscape = constraints[1]
        blurEffectViewWidthConstraintPortrait = constraints[2]
        blurEffectViewHeightConstraintPortrait = constraints[3]
        blurEffectView.layer.cornerRadius = 15.0
        blurEffectView.clipsToBounds = true
    }
    
    func setPickerStackViewConstraints() {
        let constraints = getConstraints(view: self.pickerStackView)
        
        self.pickerStackViewWidthConstraintLandscape = constraints[0]
        self.pickerStackViewHeightConstraintLandscape = constraints[1]
        self.pickerStackViewWidthConstraintPortrait = constraints[2]
        self.pickerStackViewHeightConstraintPortrait = constraints[3]
        self.pickerStackView.layer.cornerRadius = 15.0
        self.pickerStackView.clipsToBounds = true
    }
    
    
    func getConstraints(view: UIView, center: Bool = false) -> [NSLayoutConstraint] {
        view.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        if center || !iPhone {
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        }
        else {
            view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        }
        self.landscape = UIApplication.shared.statusBarOrientation.isLandscape
        return getSizeConstraints(view: view, landscape: self.landscape, fullScreen: center)
    }
    
    func getSizeConstraints(view: UIView, landscape: Bool, fullScreen: Bool) -> [NSLayoutConstraint] {
        
        var widthLandscapeMultiplier: CGFloat = 1
        var heightLandscapeMultiplier: CGFloat = 1
        var widthPortraitMultiplier: CGFloat = 1
        var heightPortraitMultiplier: CGFloat = 1
        
        if !fullScreen {
            if iPhone {
                heightLandscapeMultiplier = 0.6
                heightPortraitMultiplier = 0.4
            }
            else {
                widthLandscapeMultiplier = 0.7
                heightLandscapeMultiplier = 0.33//0.32
                widthPortraitMultiplier = 0.85
                heightPortraitMultiplier = 0.25
            }
        }
        
        let widthLandscape = view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: widthLandscapeMultiplier)
        let heightLandscape = view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: heightLandscapeMultiplier)
        let widthPortrait = view.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: widthPortraitMultiplier)
        let heightPortrait = view.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: heightPortraitMultiplier)
        
        return [widthLandscape, heightLandscape, widthPortrait, heightPortrait]
    }
    
    func activateConstraints() {
        self.landscape = UIApplication.shared.statusBarOrientation.isLandscape
        
        if self.landscape {
            shadowViewWidthConstraintPortrait.isActive = false
            shadowViewHeightConstraintPortrait.isActive = false
            blurEffectViewWidthConstraintPortrait.isActive = false
            blurEffectViewHeightConstraintPortrait.isActive = false
            pickerStackViewWidthConstraintPortrait.isActive = false
            pickerStackViewHeightConstraintPortrait.isActive = false
            
            shadowViewWidthConstraintLandscape.isActive = true
            shadowViewHeightConstraintLandscape.isActive = true
            blurEffectViewWidthConstraintLandscape.isActive = true
            blurEffectViewHeightConstraintLandscape.isActive = true
            pickerStackViewWidthConstraintLandscape.isActive = true
            pickerStackViewHeightConstraintLandscape.isActive = true
        }
        else {
            shadowViewWidthConstraintLandscape.isActive = false
            shadowViewHeightConstraintLandscape.isActive = false
            blurEffectViewWidthConstraintLandscape.isActive = false
            blurEffectViewHeightConstraintLandscape.isActive = false
            pickerStackViewWidthConstraintLandscape.isActive = false
            pickerStackViewHeightConstraintLandscape.isActive = false
            
            shadowViewWidthConstraintPortrait.isActive = true
            shadowViewHeightConstraintPortrait.isActive = true
            blurEffectViewWidthConstraintPortrait.isActive = true
            blurEffectViewHeightConstraintPortrait.isActive = true
            pickerStackViewWidthConstraintPortrait.isActive = true
            pickerStackViewHeightConstraintPortrait.isActive = true
        }
        /*
        // Mejor solución pero el orden importa :(
        shadowViewWidthConstraintLandscape.isActive = self.landscape
        shadowViewHeightConstraintLandscape.isActive = self.landscape
        blurEffectViewWidthConstraintLandscape.isActive = self.landscape
        blurEffectViewHeightConstraintLandscape.isActive = self.landscape
        pickerStackViewWidthConstraintLandscape.isActive = self.landscape
        pickerStackViewHeightConstraintLandscape.isActive = self.landscape
        
        shadowViewWidthConstraintPortrait.isActive = !self.landscape
        shadowViewHeightConstraintPortrait.isActive = !self.landscape
        blurEffectViewWidthConstraintPortrait.isActive = !self.landscape
        blurEffectViewHeightConstraintPortrait.isActive = !self.landscape
        pickerStackViewWidthConstraintPortrait.isActive = !self.landscape
        pickerStackViewHeightConstraintPortrait.isActive = !self.landscape
         */
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
        let middleButton: UIBarButtonItem!
        middleButton = UIBarButtonItem(title: "Overwrite", style: .plain, target: self, action: #selector(overwriteClick))
        middleButton.tintColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        if self.numUserPrograms == 0 {
            middleButton.isEnabled = false
        }
        
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
        toolBar.layer.cornerRadius = 15.0
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
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row >= numUserPrograms {
            print(row)
            self.toolBar.items?[2].isEnabled = false
        }
        else {
            self.toolBar.items?[2].isEnabled = true
        }
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
        
        shadowView.removeFromSuperview()
        blurEffectView.removeFromSuperview()
        pickerStackView.removeFromSuperview()
    }
    
    func isHidden() -> Bool {
        return self.blurEffectView.alpha == 0 && self.picker.alpha == 0 && self.toolBar.alpha == 0
    }
}
