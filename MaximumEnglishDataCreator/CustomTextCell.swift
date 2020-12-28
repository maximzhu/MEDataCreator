//
//  CustomTextCell.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 11/10/19.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa

enum ColumnType:String, CaseIterable {
    case question = "question"
    case answer = "answer"
    case notes = "notes"
    case alternatives = "alternate"
    case displayAnswer = "display_answer"
    
}

class CustomTextCell: NSTextFieldCell {

    
    var column:ColumnType = .question
    
    @IBInspectable
    var columnNumber:Int {
        
        get { return ColumnType.allCases.firstIndex(of: self.column)!}
        set {
            var index = min(newValue, ColumnType.allCases.count) - 1
            if index < 0 { index = 0 }
            
            self.column = ColumnType.allCases[index]
            
        }
        
        
    }
    
    
}
