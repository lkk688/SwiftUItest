//
//  String+Extension.swift
//  SwiftUItest
//
//  Created by Kaikai Liu on 4/9/20.
//  Copyright © 2020 CMPE277. All rights reserved.
//

import Foundation

extension String {
    func capitalizeFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }
    
    func localizaed(comment: String, num: Int) -> String {
        let str = NSLocalizedString(self, comment: comment)
        return String.localizedStringWithFormat(str, num)
    }
    
    //let formatString = NSLocalizedString("You have sold 1000 apps in %d months",
    //                                     comment: "Time to sell 1000 apps")
    //salesCountLabel.text = String.localizedStringWithFormat(formatString, period)
}
