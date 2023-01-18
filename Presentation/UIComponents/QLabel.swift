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
                font = UIFont(name: "Inter-Bold", size: 48)
                
            } else if labelType == QLabelType.main.rawValue {
                font = UIFont(name: "Inter-SemiBold", size: 18)

            } else if labelType == QLabelType.regular.rawValue {
                font = UIFont(name: "Inter-Medium", size: 16)
            }
            
            adjustsFontForContentSizeCategory = true
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
}
