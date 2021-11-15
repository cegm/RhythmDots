//
//  SessionHandler.swift
//  RhythmDots
//
//  Created by Carlos Eduardo Gil Mezta on 14/11/21.
//  Copyright © 2021 Eduardo Gil. All rights reserved.
//

import Foundation
import Firebase

class SessionHandler {
    var sessionCode = "-"
    var host: String = "-"
    var guest: String = "-"
    var status: String = "-"
    
    
    
    
    
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
            self.ref.child("sessions").child(self.sessionCode).setValue(["host":self.host])
        }
    }
    
    func sendParameters(columnsNumber: Int, rowsNumber: Int, densityNumber: Int, metronome: Bool, tempo: Double, color1: Int, color2: Int) {
        if self.sessionCode != "-" {
            let parameters = ["columnsNumber": columnsNumber,
                              "rowsNumber": rowsNumber,
                              "densityNumber": densityNumber,
                              "metronome": metronome,
                              "tempo": tempo,
                              "color1": color1,
                              "color2": color2]  as [String : Any]
            
            self.ref.child("sessions").child(self.sessionCode).updateChildValues(parameters)
        }
    }
    
    func hostSession() {
        self.ref.child("sessions").child(self.sessionCode).observe(.value) { snapshot in
          if snapshot.hasChild("guestIsActive") {
                
                
                let value = snapshot.value as? NSDictionary
                let guestJoined = value?["guestIsActive"] as? Bool ?? false
                if guestJoined {
                    print("Guest Joineddd!!!!!!")
                }
                else {
                    print("Guest left :(")
                }
            }
            else {
                print("no child")
            }
        }
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
    
    func getParameters(completion: @escaping ([String: Any]?, Error?) -> Void) {
        var columnsNumber: Int = 5
        var rowsNumber: Int = 5
        var densityNumber: Int = 50
        var metronome: Bool = true
        var tempo: Double = 60
        var color1: Int = 0
        var color2: Int = 0
        
        
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
                
                let parameters = ["columnsNumber": columnsNumber,
                                  "rowsNumber": rowsNumber,
                                  "densityNumber": densityNumber,
                                  "metronome": metronome,
                                  "tempo": tempo,
                                  "color1": color1,
                                  "color2": color2]  as [String : Any]
                
                completion(parameters, nil)
            }
            else {
                completion(nil, nil)
            }
        })
    }
    
 
    func changeGuestStatus(guestIsActive: Bool) {
        if self.sessionCode != "-" {
            self.ref.child("sessions").child(self.sessionCode).updateChildValues(["guestIsActive":guestIsActive])
        }
    }
}
