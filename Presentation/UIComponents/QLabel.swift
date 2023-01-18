//
//  QLabel.swift
//  QuoridorGame
//
//  Created by Andrea Colussi on 06/01/23.
//

import UIKit

enum QLabelType : String {
    case title
    case main
    case regular
}

@IBDesignable class QLabel : UILabel {
    
    
    @IBInspectable var labelType : String = "" {
        didSet {
            if labelType == QLabelType.title.rawValue {
                font = titleFont
                
            } else if labelType == QLabelType.main.rawValue {
                font = mainFont

            } else if labelType == QLabelType.regular.rawValue {
                font = regularFont
            }
            
            adjustsFontForContentSizeCategory = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
}
