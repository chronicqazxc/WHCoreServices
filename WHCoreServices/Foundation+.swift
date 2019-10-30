//
//  Foundation+.swift
//  WHCoreServices
//
//  Created by Hsiao, Wayne on 2019/9/29.
//  Copyright © 2019 Wayne Hsiao. All rights reserved.
//

import Foundation

extension CFString {
    var toString: String {
        return String(self)
    }
}

extension Dictionary {
    var toCFDictionary: CFDictionary {
        return self as CFDictionary
    }
}
