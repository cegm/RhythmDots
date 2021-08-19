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
        
        let docRef = Firestore.firestore().collection("usersPrograms").document(self.uid)

        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                print("Document data: \(dataDescription)")
                
                //print(document.data()?["program1"].)
                
                //print(document.data()?["program1"] as? [String: Any])
            } else {
                print("Document does not exist")
            }
        }
    }
}
