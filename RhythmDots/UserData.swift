//
//  UserData.swift
//  RhythmDots
//
//  Created by Eduardo Gil on 19/08/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import Foundation
import FirebaseFirestore

class UserData {
    var uid: String = "-"
    var userPrograms: [[String: Any]] = []
    let maxNumUserPrograms = 5
    
    init(uid: String, completion: @escaping (UserData?, Error?) -> Void) {
        self.uid = uid
        
        self.setUserPrograms() { (userPrograms, error) in
            if let error = error {
                print("Error loading user data: \(error)")
                completion(nil, error)
                return
            }
            if let userPrograms = userPrograms {
                self.userPrograms = userPrograms
                completion(self, error)
            }
            
        }
    }
    
    init() {
        self.userPrograms = [self.getDefaultProgramDictionary()]
    }

    
    func setUserPrograms(completion: @escaping ([[String: Any]]?, Error?) -> Void) {
        var userPrograms: [[String: Any]] = [self.getDefaultProgramDictionary()]

        if self.uid != "-" {
            let ref = Firestore.firestore().collection("usersPrograms").document(self.uid)
            ref.getDocument { (document, error) in
                if let error = error {
                    // Return default user programs and error message
                    completion(userPrograms, error)
                    return
                }
                if let document = document, document.exists {
                    
                    if let documentData = document.data() {
                        var n = 0
                        userPrograms = []
                        repeat {
                            if let currentProgramData = documentData["program\(n)"] as? [String:Any] {
                                let name = currentProgramData["name"] as? String ?? "Default"
                                let columnsNumber = currentProgramData["columnsNumber"] as? Int ?? 5
                                let rowsNumber = currentProgramData["rowsNumber"] as? Int ?? 5
                                let densityNumber = currentProgramData["densityNumber"] as? Int ?? 50
                                let metronome = currentProgramData["metronome"] as? Bool ?? true
                                let tempo = currentProgramData["tempo"] as? Double ?? 60
                                let selectedColor1 = currentProgramData["selectedColor1"] as? Int ?? 0
                                let selectedColor2 = currentProgramData["selectedColor2"] as? Int ?? 0
                                
                                let currentProgram = self.getProgramDictionary(name: name,
                                                                               columnsNumber: columnsNumber,
                                                                               rowsNumber: rowsNumber,
                                                                               densityNumber: densityNumber,
                                                                               metronome: metronome,
                                                                               tempo: tempo,
                                                                               selectedColor1: selectedColor1,
                                                                               selectedColor2: selectedColor2)
                                userPrograms.append(currentProgram)
                            }
                            n = n + 1
                        } while n <= self.maxNumUserPrograms
                    }
                    completion(userPrograms, nil)
                    //return
                }
            }
        }
    }
    
    func getDefaultProgramDictionary() -> [String : Any] {
        let defaultProgramDictionary: [String: Any] = self.getProgramDictionary(name: "Default",
                                                                                columnsNumber: 5,
                                                                                rowsNumber: 5,
                                                                                densityNumber: 50,
                                                                                metronome: true,
                                                                                tempo: 60,
                                                                                selectedColor1: 0,
                                                                                selectedColor2: 0)
        return defaultProgramDictionary
    }
    
    func getProgramDictionary(name: String, columnsNumber: Int, rowsNumber: Int, densityNumber: Int, metronome: Bool, tempo: Double, selectedColor1: Int, selectedColor2: Int) -> [String : Any] {
        let programDictionary = ["name": name,
                                 "columnsNumber": columnsNumber,
                                 "rowsNumber": rowsNumber,
                                 "densityNumber": densityNumber,
                                 "metronome": metronome,
                                 "tempo": tempo,
                                 "selectedColor1": selectedColor1,
                                 "selectedColor2": selectedColor2] as [String : Any]
        return programDictionary
    }
    
    func getProgramsDataArray() -> [String] {
        var programsDataArray: [String] = []
        for program in userPrograms {
            programsDataArray.append(program["name"] as! String)
        }
        return programsDataArray
    }
    
    func addUserProgram(programDictionary: [String : Any]) {
        let numUserPrograms = userPrograms.count
        
        if self.uid != "-" {
            if numUserPrograms < maxNumUserPrograms {
                let ref = Firestore.firestore().collection("usersPrograms").document(self.uid)
                ref.setData(["program\(numUserPrograms)": programDictionary], merge: true) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                    else {
                        print("Document added with ID: \(ref.documentID)")
                    }
                }
            }
        }
    }
    
    func updateUserProgram(numUserProgram: Int, programDictionary: [String : Any]) {
        let numUserPrograms = userPrograms.count
        
        if self.uid != "-" {
            if numUserProgram < numUserPrograms {
                let ref = Firestore.firestore().collection("usersPrograms").document(self.uid)
                ref.updateData(["program\(numUserProgram)": programDictionary]) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    }
                    else {
                        print("Document added with ID: \(ref.documentID)")
                    }
                }
            }
        }
    }
    
}
