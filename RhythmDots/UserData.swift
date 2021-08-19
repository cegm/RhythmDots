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
        print("Me instancio?")
        self.uid = uid
        self.userPrograms = getUserProgramDictionary()
        print(self.uid)
        print(self.userPrograms)
    }
    
    init() {
        self.userPrograms = [self.getDefaultProgramDictionary()]
    }

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
    }
    
    
    
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
