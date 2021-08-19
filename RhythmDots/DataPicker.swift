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
                if let doumentData = document.data() {
                    print(doumentData)
                    
                    var keepRetrieving = true
                    var n = 0
                    repeat {
                        if let currentProgram = doumentData["program\(n )"] {
                            print(currentProgram)
                            
                            
                            //for notificaton in userNotifications  {
                            //    let body = notificaton["body"] as? String ?? ""
                            //    let title = notificaton["title"] as? String ?? ""
                            //    print(body, title)
                            //}
                        }
                        else {
                            keepRetrieving = false
                        }
                        n = n + 1
                    } while keepRetrieving
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
