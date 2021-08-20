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
    
    init(uid: String) {
        self.uid = uid
        self.userPrograms = [self.getDefaultProgramDictionary()]
    }
    
    init() {
        self.userPrograms = [self.getDefaultProgramDictionary()]
    }
    /*
    func getUserPrograms() {
        var userPrograms: [[String: Any]] = [self.getDefaultProgramDictionary()]
        self.userPrograms = userPrograms
        
        if self.uid != "-" {
            getUserProgramData { (documentData, error) in
                print("por kkk")
                if let error = error {
                   print(error)
                   return
                }
                if let documentData = documentData {
                    var n = 0
                    userPrograms = []
                    repeat {
                        if let currentProgramData = documentData["program\(n)"] as? [String:Any] {
                        
                            print("Sí hay datos!")
                            print(currentProgramData)
                            
                            let columnsNumber = currentProgramData["columnsNumber"] as? Int ?? 5
                            let rowsNumber = currentProgramData["rowsNumber"] as? Int ?? 5
                            let densityNumber = currentProgramData["densityNumber"] as? Int ?? 50
                            var metronome: Bool = true
                            var tempo = currentProgramData["tempo"] as? Double ?? 60
                            let selectedColor1 = currentProgramData["color1"] as? Int ?? 0
                            let selectedColor2 = currentProgramData["color2"] as? Int ?? 0
                            
                            if tempo <= 0 {
                                metronome = false
                                tempo = 60
                            }
                            else {
                                metronome = true
                            }
                            let currentProgram = self.getProgramDictionary(columnsNumber: columnsNumber,
                                                                      rowsNumber: rowsNumber,
                                                                      densityNumber: densityNumber,
                                                                      metronome: metronome,
                                                                      tempo: tempo,
                                                                      selectedColor1: selectedColor1,
                                                                      selectedColor2: selectedColor2)
                            userPrograms.append(currentProgram)
                        }
                        n = n + 1
                    } while n <= 5
                    self.userPrograms = userPrograms
                }
                
            }
            if let documentData: [String: Any] = ["program0":["selectedColor2": 1, "metronome": true, "tempo": 120.0, "columnsNumber": 9, "selectedColor1": 3, "densityNumber": 100, "rowsNumber": 17], "program1":["selectedColor2": 6, "metronome": true, "tempo": 100.0, "columnsNumber": 6, "selectedColor1": 4, "densityNumber": 100, "rowsNumber": 6]] {
                var n = 0
                userPrograms = []
                repeat {
                    if let currentProgramData = documentData["program\(n)"] as? [String:Any] {
                    
                        print("Sí hay datos!")
                        
                        let columnsNumber = currentProgramData["columnsNumber"] as? Int ?? 5
                        let rowsNumber = currentProgramData["rowsNumber"] as? Int ?? 5
                        let densityNumber = currentProgramData["densityNumber"] as? Int ?? 50
                        var metronome: Bool = true
                        var tempo = currentProgramData["tempo"] as? Double ?? 60
                        let selectedColor1 = currentProgramData["color1"] as? Int ?? 0
                        let selectedColor2 = currentProgramData["color2"] as? Int ?? 0
                        
                        if tempo <= 0 {
                            metronome = false
                            tempo = 60
                        }
                        else {
                            metronome = true
                        }
                        let currentProgram = self.getProgramDictionary(columnsNumber: columnsNumber,
                                                                  rowsNumber: rowsNumber,
                                                                  densityNumber: densityNumber,
                                                                  metronome: metronome,
                                                                  tempo: tempo,
                                                                  selectedColor1: selectedColor1,
                                                                  selectedColor2: selectedColor2)
                        userPrograms.append(currentProgram)
                    }
                    n = n + 1
                } while n <= 5
            }
        }
    }*/
    
    func getUserProgramData(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let docRef = Firestore.firestore().collection("usersPrograms").document(self.uid)
        docRef.getDocument { (document, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            if let document = document, document.exists {
                print("toy en completeishon")
                completion(document.data(), nil)
                return
            }
        }
    }
    /*
    func getUserProgramDictionary() ->  [[String: Any]]  {
        var userPrograms: [[String: Any]] = [self.getDefaultProgramDictionary()]
        
        let docRef = Firestore.firestore().collection("usersPrograms").document(self.uid)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let doumentData = document.data() {
                    var n = 0
                    userPrograms = []
                    repeat {
                        if let currentProgramData = doumentData["program\(n)"] as? [String:Any] {
                        
                            print("Sí hay datos!")
                            
                            let columnsNumber = currentProgramData["columnsNumber"] as? Int ?? 5
                            let rowsNumber = currentProgramData["rowsNumber"] as? Int ?? 5
                            let densityNumber = currentProgramData["densityNumber"] as? Int ?? 50
                            var metronome: Bool = true
                            var tempo = currentProgramData["tempo"] as? Double ?? 60
                            let selectedColor1 = currentProgramData["color1"] as? Int ?? 0
                            let selectedColor2 = currentProgramData["color2"] as? Int ?? 0
                            
                            if tempo <= 0 {
                                metronome = false
                                tempo = 60
                            }
                            else {
                                metronome = true
                            }
                            let currentProgram = self.getProgramDictionary(columnsNumber: columnsNumber,
                                                                      rowsNumber: rowsNumber,
                                                                      densityNumber: densityNumber,
                                                                      metronome: metronome,
                                                                      tempo: tempo,
                                                                      selectedColor1: selectedColor1,
                                                                      selectedColor2: selectedColor2)
                            userPrograms.append(currentProgram)
                            print(userPrograms)
                        }
                        n = n + 1
                    } while n <= 5
                    print(userPrograms)
                }
            }
            print("por aki")
        }
        print("y aki?????")
        return userPrograms
    }*/
    
    
    
    func getDefaultProgramDictionary() -> [String : Any] {
        let defaultProgramDictionary: [String: Any] = self.getProgramDictionary(columnsNumber: 5,
                                                                      rowsNumber: 5,
                                                                      densityNumber: 50,
                                                                      metronome: true,
                                                                      tempo: 60,
                                                                      selectedColor1: 0,
                                                                      selectedColor2: 0)
        return defaultProgramDictionary
    }
    
    func getProgramDictionary(columnsNumber: Int, rowsNumber: Int, densityNumber: Int, metronome: Bool, tempo: Double, selectedColor1: Int, selectedColor2: Int) -> [String : Any] {
        let programDictionary = ["columnsNumber": columnsNumber,
                                 "rowsNumber": rowsNumber,
                                 "densityNumber": densityNumber,
                                 "metronome": metronome,
                                 "tempo": tempo,
                                 "selectedColor1": selectedColor1,
                                 "selectedColor2": selectedColor2] as [String : Any]
        return programDictionary
    }
}
