//
//  GameInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 28/11/22.
//

import Foundation

protocol GameInterface {
    func searchMatch() async throws
    func updatePawn(pawn : Pawn) async throws
    func updateWalls(wall : Wall) async throws
    
    var boardListener : Published<Board>.Publisher { get }
}

// Add a new document in collection "cities"
/*
db.collection("cities").document("LA").setData([
    "name": "Los Angeles",
    "state": "CA",
    "country": "USA"
]) { err in
    if let err = err {
        print("Error writing document: \(err)")
    } else {
        print("Document successfully written!")
    }
}

 public struct City: Codable {

     let name: String
     let state: String?
     let country: String?
     let isCapital: Bool?
     let population: Int64?

     enum CodingKeys: String, CodingKey {
         case name
         case state
         case country
         case isCapital = "capital"
         case population
     }

 
 let city = City(name: "Los Angeles",
                 state: "CA",
                 country: "USA",
                 isCapital: false,
                 population: 5000000)

 do {
     try db.collection("cities").document("LA").setData(from: city)
 } catch let error {
     print("Error writing city to Firestore: \(error)")
 }
 
 let washingtonRef = db.collection("cities").document("DC")

 // Set the "capital" field of the city 'DC'
 washingtonRef.updateData([
     "capital": true
 ]) { err in
     if let err = err {
         print("Error updating document: \(err)")
     } else {
         print("Document successfully updated")
     }
 }
 }
*/
