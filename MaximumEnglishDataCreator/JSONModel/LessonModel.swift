//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON




class LessonModel: Codable {
    
    
    var id:String
    var name:String
    var vocabulary:[CardModel] = []
    var grammar:[CardModel] = []
    
    
    private var _cost:Int?
    var cost:Int{
        get { return _cost ?? 0 }
        set { _cost = newValue }
    }
    
    private var _notes:String?
    var notes:String {
        get { return _notes ?? "" }
        set { _notes = newValue }
    }
    
    var image:String?
    var video:String?
    
    enum CodingKeys:String, CodingKey {
        case id
        case name
        case vocabulary
        case _cost = "cost"
        case grammar
        case _notes = "notes"
        case image
        case video
    }
    
    init(withName name:String) {
        self.id = UUID().uuidString
        self.name = name
        self.cost = 0
    }
    
}
