//
//  Extentions.swift
//  WakeUpAt
//
//  Created by Ahmed Osama on 9/1/18.
//  Copyright © 2018 Ahmed Osama. All rights reserved.
//

import Foundation

extension Float {
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toString() -> String {
        return String(self)
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    func toString() -> String {
        return String(self)
    }
}
