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
                self.font = UIFont(name: "Inter-Bold", size: 48)
                
            } else if labelType == QLabelType.main.rawValue {
                self.font = UIFont(name: "Inter-Medium", size: 14)

            } else if labelType == QLabelType.regular.rawValue {
                self.font = UIFont(name: "Inter-Regular", size: 12)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    
}
