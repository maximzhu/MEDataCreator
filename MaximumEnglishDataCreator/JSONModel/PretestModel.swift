//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON




class PretestModel: Codable {
    
    
    var id:String
    var vocabulary:[CardModel] = []
    var grammar:[CardModel] = []
    
    private var _notes:String?
    var notes:String {
        get { return _notes ?? "" }
        set { _notes = newValue }
    }

    enum CodingKeys:String, CodingKey {
        case id
        case vocabulary
        case grammar
        case _notes = "notes"
    }
    
    init() { id = UUID().uuidString }
    
}
