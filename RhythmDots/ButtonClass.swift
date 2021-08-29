//
//  ButtonClass.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 28/08/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import Foundation
import UIKit

class ButtonClass: NSObject {
    
    var button: UIButton!
    
    override init() {
        super.init()  // call this so that you can use self below
        button = UIButton(frame:CGRect(x: 100, y: 100, width: 100, height: 40))
        button.setTitle("TEST", for:.normal)
        button.backgroundColor = .green
        button.addTarget(self, action: #selector(tapButton(_:)), for: .touchUpInside)
    }

    @objc func tapButton(_ sender: UIButton) {
        print("TAP Button")
    }

    // Add deinit to see when this object is deinitialized.  When
    // instance is local to viewDidLoad() this object gets freed
    // when viewDidLoad() finishes.
    deinit {
        print("Oops, the Test object has been deinitialized")
    }
}
