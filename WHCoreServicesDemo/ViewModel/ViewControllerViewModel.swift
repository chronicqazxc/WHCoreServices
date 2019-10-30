//
//  ViewControllerViewModel.swift
//  WHCoreServicesDemo
//
//  Created by Hsiao, Wayne on 2019/10/10.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation
import WHCoreServices

class ViewControllerViewModel {
    
    var items: [ComponentType] {
        return [
            .email,        // (0, 0)
            .password,     // (0, 1)
            .empty,        // (0, 2)
            .empty,        // (0, 3)
            .submitButton, // (0, 4) Save/Update button
            .submitButton  // (0, 5) Retrieve button
        ]
    }
    
    fileprivate var email: String = ""
    fileprivate var password: String = ""
    
    func numberOfSection() -> Int {
        return 1
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return items.count
    }
    
    func cellTypeBy(indexPath: IndexPath) -> ComponentType? {
        guard indexPath.row < items.count else {
            return nil
        }
        
        return items[indexPath.row]
    }
    
    func placeholderBy(indexPath: IndexPath) -> String {
        switch cellTypeBy(indexPath: indexPath) {
        case .email:
            return "Email"
        case .password:
            return "Password"
        default:
            return ""
        }
    }
    
    func placeholderBy(component: ComponentType) -> String {
        switch component {
        case .email:
            return "Email"
        case .password:
            return "Password"
        default:
            return ""
        }
    }
    
    func buttonTitleBy(indexPath: IndexPath) -> String {
        if indexPath.row == 4 {
            return passwordExistFor(account: email) == true ? "Update" : "Save"
        } else if indexPath.row == 5 {
            return "Retrieve"
        } else {
            return ""
        }
    }
    
    func submitButtonIndexPath() -> IndexPath {
        return IndexPath(row: 4, section: 0)
    }
    
    func retrieveButtonIndexPath() -> IndexPath {
        return IndexPath(row: 5, section: 0)
    }
    
    func passwordExistFor(account: String) -> Bool {
        return UserDefaults.standard.bool(forKey: account)
    }
    
    func updateEmail(_ email: String) {
        self.email = email
    }
    
    func updatePassword(_ password: String) {
        self.password = password
    }
    
    func save(completeHandler: @escaping (_ isSuccess: Bool) -> Void) {
        print("\(email) - \(password)")
        
        let keychainWrapper = KeychainWrapper(queryable: DemoQueryable.shared)
        do {
            try keychainWrapper.setValue(password, forAccount: email)
            UserDefaults.standard.set(true, forKey: email)
            completeHandler(true)
        } catch {
            print(error)
            completeHandler(false)
        }
    }
    
    func retrieve() -> String {
        print("\(email) - \(password)")
        let keychainWrapper = KeychainWrapper(queryable: DemoQueryable.shared)
        do {
            guard let value = try keychainWrapper.getValue(for: email) else {
                print("Not Found")
                return "Not Found"
            }
            return value
        } catch {
            print(error)
            return "Error"
        }
    }
}
