//
//  Date+Shortcuts.swift
//  FBLA Project 1
//
//  Created by Mason Dale on 3/4/18.
//  Copyright © 2018 Mason Dale. All rights reserved.
//

import Foundation

extension Date {
    //Returns string value of current date
    func getCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
        let convertedDate = dateFormatter.string(from: self)
        return convertedDate
    }
    
    //Returns string value of future book due date
    func getDueDate() -> String {
        var components = DateComponents()
        components.setValue(14, for: .day)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd hh:mm:ss"
        let expirationDate = Calendar.current.date(byAdding: components, to: self, wrappingComponents: false)
        let conversionDate = dateFormatter.string(from: expirationDate!)
        return conversionDate
    }
}
