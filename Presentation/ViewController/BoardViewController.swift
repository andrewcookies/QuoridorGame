//
//  BoardViewController.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 01/12/22.
//

import UIKit
import Combine

class BoardViewController: UIViewController {

    private var viewModel : BoardViewModelProtocol?
    private var listener : GameInputViewModelProtocol?

    private var subscribers: [AnyCancellable] = []

    private var indexPawn = 0
    private var indexWall = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        setupObserver()
    }

    
    init(viewModel: BoardViewModelProtocol,
         listener : GameInputViewModelProtocol?) {
        super.init(nibName: String(describing: "BoardViewController"), bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObserver(){
        listener?.gameEventListener.receive(on: DispatchQueue.main).sink(receiveValue: { [weak self] board in
            guard let self = self else { return }
           
            print("BoardViewController - board updated")
            
        }).store(in: &subscribers)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.

     // Pass the selected object to the new view controller.
    }
    */

    
    @IBAction func searchMatch(_ sender: UIButton) {
        viewModel?.initializeMatch()
    }
    
    @IBAction func putWall(_ sender: UIButton) {
        indexPawn += 1
        viewModel?.movePawn(index: indexPawn)
    }
    
    @IBAction func insertWall(_ sender: UIButton) {
        indexWall += 1
        viewModel?.insertWall(index: indexWall)
    }
    
    @IBAction func quit(_ sender: UIButton) {
        viewModel?.quitMatch()
    }
    
}
