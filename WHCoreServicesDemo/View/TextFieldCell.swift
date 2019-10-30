//
//  TextFieldCell.swift
//  WHCoreServicesDemo
//
//  Created by Hsiao, Wayne on 2019/10/10.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {

    @IBOutlet weak var textField: UITextField! {
        didSet {
            textField.delegate = self
        }
    }
    
    static let nibName = "TextFieldCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension TextFieldCell: UITextFieldDelegate {
    
}
