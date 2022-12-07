//
//  GameLog.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 07/12/22.
//

import Foundation
final class GameLog {
    
    static let shared = GameLog()
    
    func debug(message : String, className : String){
        let log = "GAMELOG [" + className + "] - " + message
        print("log")
    }
}
