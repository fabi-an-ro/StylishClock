//
//  DateFormatter+Exensions.swift
//  
//
//  Created by Fabian Rottensteiner on 07.08.22.
//

import Foundation

extension DateFormatter {
    func string(from date: Date, with format: TimeFormat) -> String {
        let formatter = DateFormatter()
        
        formatter.dateFormat = format.rawValue
        
        return formatter.string(from: date)
    }
}
