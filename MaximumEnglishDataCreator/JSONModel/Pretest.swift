//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON




class Pretest: Codable {
    
    
    var id:String
    var cards:[Card] = []
    
    private var _notes:String?
    var notes:String {
        get { return _notes ?? "" }
        set { _notes = newValue }
    }

    enum CodingKeys:String, CodingKey {
        case id
        case cards
        case _notes = "notes"
    }
    
    init() { id = UUID().uuidString }
    
}
