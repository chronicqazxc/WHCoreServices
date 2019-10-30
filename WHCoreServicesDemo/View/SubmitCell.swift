//
//  SubmitCell.swift
//  WHCoreServicesDemo
//
//  Created by Hsiao, Wayne on 2019/10/10.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit

protocol SubmitCellDelegate: class {
    func submitButtonTapped(button: UIButton)
}

class SubmitCell: UITableViewCell {
    
    static let nibName = "SubmitCell"

    @IBOutlet weak var submitButton: UIButton!
    weak var delegate: SubmitCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        delegate?.submitButtonTapped(button: submitButton)
    }
    
    func buttonName(_ title: String) {
        submitButton.setTitle(title, for: .normal)
    }
}
