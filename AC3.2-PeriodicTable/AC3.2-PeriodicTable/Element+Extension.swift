//
//  Element+Extension.swift
//  AC3.2-PeriodicTable
//
//  Created by Tom Seymour on 12/21/16.
//  Copyright © 2016 C4Q-3.2. All rights reserved.
//

import Foundation

extension Element {
    
    func populate(from dict: [String: Any]) {
        if let name = dict["name"] as? String,
            let group = dict["group"] as? Int,
            let number = dict["number"] as? Int,
            let symbol = dict["symbol"] as? String,
            let weight = dict["weight"] as? Double {
            
            self.number = Int64(number)
            self.name = name
            self.group = Int64(group)
            self.symbol = symbol
            self.weight = weight
        }
    }
}

