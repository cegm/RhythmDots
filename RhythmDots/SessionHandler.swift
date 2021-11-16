//
//  SessionHandler.swift
//  RhythmDots
//
//  Created by Carlos Eduardo Gil Mezta on 14/11/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import Foundation
import Firebase

protocol SessionHandlerDelegate: NSObject {
    func sessionStatusChanged(message: String)
}

class SessionHandler {
    var sessionCode = "-"
    var host: String = "-"
    var guest: String = "-"
    var status: String = "-"
    
    weak var delegate:SessionHandlerDelegate!
    
    
    
    var ref: DatabaseReference!
    
    init(host: String) {
        self.ref = Database.database().reference()
        
        self.host = host
        self.setSessionCode()
        //self.hostSession()
    }
    
    init() {
        self.ref = Database.database().reference()
    }
    
    func setSessionCode(){
        var sessionCode: String!
        
        self.ref.child("sessions").getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            
            sessionCode = self.generateSessionCode()
            while snapshot.hasChild(sessionCode) {
                sessionCode = self.generateSessionCode()
            }
            self.sessionCode = sessionCode
            self.registerSession()
            
        })
    }
    
    func generateSessionCode() -> String {
        let length: Int = 4
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            var sessionCode = ""
            for _ in 0 ..< length {
                sessionCode.append(letters.randomElement()!)
            }
        return sessionCode
    }
    
    func registerSession() {
        if self.sessionCode != "-" {
            self.ref.child("sessions").child(self.sessionCode).setValue(["host":self.host, "status": "Pairing"])
        }
    }
    
    func sendParameters(columnsNumber: Int, rowsNumber: Int, densityNumber: Int, metronome: Bool, tempo: Double, color1: Int, color2: Int, gridNumbers: String) {
        if self.sessionCode != "-" {
            let parameters = ["columnsNumber": columnsNumber,
                              "rowsNumber": rowsNumber,
                              "densityNumber": densityNumber,
                              "metronome": metronome,
                              "tempo": tempo,
                              "color1": color1,
                              "color2": color2,
                              "gridNumbers": gridNumbers]  as [String : Any]
            
            self.ref.child("sessions").child(self.sessionCode).updateChildValues(parameters)
            self.hostReady()
        }
    }
    
    func waitForGuestToJoin() {
        let field: String = "guestJoined"
        let messageDictionary: [String: String] = ["true": "Guest joined"]
        self.listenForChangesInSessionField(field: field, messageDictionary: messageDictionary)
    }
    
    func waitForHostToSendParameters() {
        let field: String = "hostReady"
        let messageDictionary: [String: String] = ["true": "Host ready"]
        self.listenForChangesInSessionField(field: field, messageDictionary: messageDictionary)
    }
    
    func waitForGuestToGetParameters() {
        let field: String = "guestReady"
        let messageDictionary: [String: String] = ["true": "Guest ready"]
        self.listenForChangesInSessionField(field: field, messageDictionary: messageDictionary)
    }
    
    func listenToGameStatus() {
        let field: String = "status"
        let messageDictionary: [String: String] = ["Play": "Play",
                                                   "Pause": "Pause",
                                                   "Restart": "Restart",
                                                   "Reset": "Reset",
                                                   "Over": "Over"]
        self.listenForChangesInSessionField(field: field, messageDictionary: messageDictionary)
    }
    
    /*
    func listenForChangesInSessionField(field: String, messageDictionary: [String: String]) {
        self.ref.child("sessions").child(self.sessionCode).observe(.value) { snapshot in
            if snapshot.hasChild(field) {
                let snaphshotValue = snapshot.value as? NSDictionary
                let fieldValue = snaphshotValue?[field] as? String ?? "Not found"
                
                let message = messageDictionary[fieldValue] ?? "Not found"
                print(message)
                self.delegate.sessionStatusChanged(message: message)
            }
        }
    }*/
    
    func listenForChangesInSessionField(field: String, messageDictionary: [String: String]) {
        print("listenForChangesInSessionField: \(field)")
        self.ref.child("sessions").child(self.sessionCode).child(field).observe(.value) { snapshot in
            let fieldValue = snapshot.value as? String  ?? "Not found"
            let message = messageDictionary[fieldValue] ?? "Not found"
            print("\(field): \(fieldValue) - \(message)")
            self.delegate.sessionStatusChanged(message: message)
        }
    }
    
    func resetSession(removeGuest: Bool, removeGuestJoinedListener: Bool = false) {
        print("inicio")
        /*
        self.deleteField(field: "columnsNumber")
        self.deleteField(field: "rowsNumber")
        self.deleteField(field: "densityNumber")
        self.deleteField(field: "metronome")
        self.deleteField(field: "tempo")
        self.deleteField(field: "color1")
        self.deleteField(field: "color2")
        self.deleteField(field: "gridNumbers")
         */
        
        if removeGuest {
            self.deleteField(field: "guestJoined")
            
        }
        if removeGuestJoinedListener {
            self.ref.child("sessions").child(self.sessionCode).child("guestJoined").removeAllObservers()
        }
        print("mitad")
        self.deleteField(field: "hostReady")
        self.ref.child("sessions").child(self.sessionCode).child("hostReady").removeAllObservers()
        
        self.deleteField(field: "guestReady")
        self.ref.child("sessions").child(self.sessionCode).child("guestReady").removeAllObservers()
        
        self.deleteField(field: "status")
        self.ref.child("sessions").child(self.sessionCode).child("status").removeAllObservers()
        print("fin")
    }
    
    func deleteField(field: String) {
        self.ref.child("sessions").child(self.sessionCode).child(field).removeValue(completionBlock: { (error, refer) in
            guard error == nil else {
              print(error!.localizedDescription)
              return;
            }
            print(refer)
            print("Child Removed Correctly")
        })
    }
    
    func terminateSession() {
        self.ref.child("sessions").child(self.sessionCode).removeValue(completionBlock: { (error, refer) in
            guard error == nil else {
              print(error!.localizedDescription)
              return;
            }
            print(refer)
            print("Child Removed Correctly")
        })
    }
    
    func joinSession(sessionCode: String, completion: @escaping (Bool?, Error?) -> Void) {
        self.ref.child("sessions").getData(completion:  { error, snapshot in
            if let error = error {
                completion(false, error)
            }
            if snapshot.hasChild(sessionCode.uppercased()) {
                self.sessionCode = sessionCode.uppercased()
                self.guestJoined()
                completion(true, nil)
            }
            else {
                completion(false, error)
            }
        })
    }
    
    /*
    func joinSession(sessionCode: String, completion: @escaping (Bool?, [String: Any]?, Error?) -> Void) {
        self.ref.child("sessions").getData(completion:  { error, snapshot in
            if let error = error {
                completion(false, nil, error)
            }
            if snapshot.hasChild(sessionCode.uppercased()) {
                self.sessionCode = sessionCode.uppercased()
                self.changeGuestStatus(guestIsActive: true)
                
                self.getParameters()  { (parameters, error) in
                    if let error = error {
                        print("SessionHandler.swift: Error getting parameters: \(error)")
                    }
                    if parameters != nil {
                        completion(true, parameters, nil)
                    }
                }
            }
            else {
                completion(false, nil, error)
            }
        })
    }
     */
    
    func getParameters(completion: @escaping ([String: Any]?, Error?) -> Void) {
        var columnsNumber: Int = 5
        var rowsNumber: Int = 5
        var densityNumber: Int = 50
        var metronome: Bool = true
        var tempo: Double = 60
        var color1: Int = 0
        var color2: Int = 0
        var gridNumbersDescription: String = "[]"
        var gridNumbers: [Int] = []
        
        
        self.ref.child("sessions").child(self.sessionCode).getData(completion:  { error, snapshot in
            if let error = error {
                completion(nil, error)
            }
            if let value = snapshot.value as? NSDictionary {
                columnsNumber = value["columnsNumber"] as? Int ?? 5
                rowsNumber = value["rowsNumber"] as? Int ?? 5
                densityNumber = value["densityNumber"] as? Int ?? 50
                metronome = value["metronome"] as? Bool ?? true
                tempo = value["tempo"] as? Double ?? 60
                color1 = value["color1"] as? Int ?? 0
                color2 = value["color2"] as? Int ?? 0
                gridNumbersDescription = value["gridNumbers"] as? String ?? "[]"
                
                
                for char in gridNumbersDescription {
                    let number = Int(String(char))
                    if number != nil {
                        gridNumbers.append(number!)
                    }
                }
                
                let parameters = ["columnsNumber": columnsNumber,
                                  "rowsNumber": rowsNumber,
                                  "densityNumber": densityNumber,
                                  "metronome": metronome,
                                  "tempo": tempo,
                                  "color1": color1,
                                  "color2": color2,
                                  "gridNumbers": gridNumbers]  as [String : Any]
                
                completion(parameters, nil)
            }
            else {
                completion(nil, nil)
            }
        })
    }
    
 
    func guestJoined() {
        updateSessionField(field: "guestJoined", value: "true")
    }
    
    func hostReady() {
        updateSessionField(field: "hostReady", value: "true")
    }
    
    func guestReady() {
        updateSessionField(field: "guestReady", value: "true")
    }
    
    func changeGameStatus(status: String) {
        updateSessionField(field: "status", value: status)
    }
    
    func updateSessionField(field: String, value: String) {
        if self.sessionCode != "-" {
            self.ref.child("sessions").child(self.sessionCode).updateChildValues([field:value])
        }
    }
}
