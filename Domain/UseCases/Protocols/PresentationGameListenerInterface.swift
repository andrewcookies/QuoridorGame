//
//  PresentationGameListenerInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 03/12/22.
//

import Foundation
//To be implemented by ViewModel
protocol PresentationGameListenerInterface {
    func updatePresentationLayer(game : Game)
}
