//
//  DataPicker.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 18/08/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import UIKit
import Foundation
import FirebaseAuth
import FirebaseFirestore



class DataPicker {
    var uid: String
    
    init(uid: String) {
        self.uid = uid
    }

    func myFunction() {
        print(self.uid)
    }
}
