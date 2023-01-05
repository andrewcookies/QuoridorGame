//
//  PresentationLayerInputListenerInterface.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 07/12/22.
//

import Foundation

protocol PresentationLayerInputListenerInterface {
    func opponentQuitMatch(game : Game)
    func opponentWonMatch(game : Game)
    func opponentMadeMove(game : Game)
    func opponentRequestRestartGame(game : Game)
}
