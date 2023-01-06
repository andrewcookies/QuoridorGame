//
//  QLabel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 06/01/23.
//

import UIKit

@IBDesignable class QLabel : UILabel {
    
    
    @IBInspectable var labelType : String = "" {
        didSet {
            //create your style
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
}
