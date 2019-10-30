//
//  ViewController.swift
//  WHCoreServicesDemo
//
//  Created by Hsiao, Wayne on 2019/9/27.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import UIKit
import WHCoreServices

enum ComponentType {
    case email
    case password
    case submitButton
    case empty
}

class ViewController: UITableViewController {
    
    let viewModel = ViewControllerViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: TextFieldCell.nibName, bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: TextFieldCell.nibName)
        
        let submitNib = UINib(nibName: SubmitCell.nibName, bundle: nil)
        self.tableView.register(submitNib, forCellReuseIdentifier: SubmitCell.nibName)
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorColor = UIColor.clear
        tableView.allowsSelection = false
        title = "Login"
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch viewModel.cellTypeBy(indexPath: indexPath) {
        case .email:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.nibName, for: indexPath)
            if let textCell = cell as? TextFieldCell {
                textCell.textField.placeholder = viewModel.placeholderBy(component: .email)
                textCell.textField.autocorrectionType = .no
                textCell.textField.delegate = self
            }
            return cell
        case .password:
            let cell = tableView.dequeueReusableCell(withIdentifier: TextFieldCell.nibName, for: indexPath)
            if let textCell = cell as? TextFieldCell {
                textCell.textField.placeholder = viewModel.placeholderBy(component: .password)
                textCell.textField.autocorrectionType = .no
                textCell.textField.delegate = self
            }
            return cell
        case .submitButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: SubmitCell.nibName, for: indexPath)
            if let submitCell = cell as? SubmitCell {
                submitCell.delegate = self
                let title = viewModel.buttonTitleBy(indexPath: indexPath)
                submitCell.submitButton.setTitle(title, for: .normal)
            }
            return cell
        case .empty:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        case .none:
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func reloadSubmitButton() {
        UIView.setAnimationsEnabled(false)
        tableView.performBatchUpdates({ [weak self] in
            self?.tableView.reloadRows(at: [viewModel.submitButtonIndexPath(),
                                            viewModel.retrieveButtonIndexPath()], with: .none)
        }, completion: nil)
    }
}

extension ViewController: UITextFieldDelegate {
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    public func textField(_ textField: UITextField,
                          shouldChangeCharactersIn range: NSRange,
                          replacementString string: String) -> Bool {
        
        guard let text = textField.text,
            let range = Range(range, in: text) else {
            return false
        }
        let updatedText = text.replacingCharacters(in: range, with: string)
        if textField.placeholder == viewModel.placeholderBy(component: .email) {
            viewModel.updateEmail(updatedText)
            reloadSubmitButton()
        } else if textField.placeholder == viewModel.placeholderBy(component: .password) {
            viewModel.updatePassword(updatedText)
        }
        return true
    }
}

extension ViewController: SubmitCellDelegate {
    func submitButtonTapped(button: UIButton) {
        if button.title(for: .normal) == "Save" || button.title(for: .normal) == "Update" {
            viewModel.save { [weak self] (success) in
                if success == true {
                    self?.showAlertViewTitl("Save/Update", message: "Success")
                } else {
                    self?.showAlertViewTitl("Save/Update", message: "Failed")
                }
            }
        } else if button.title(for: .normal) == "Retrieve" {
            showAlertViewTitl("Retrieve", message: viewModel.retrieve())
        }
        reloadSubmitButton()
    }
    
    func showAlertViewTitl(_ title: String, message: String) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "ok", style: .default, handler: nil)
        controller.addAction(action)
        present(controller, animated: true, completion: nil)
    }
}
