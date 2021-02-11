//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON




class Lesson: Codable {
    
    
    var id:String
    var name:String
    var cards:[Card] = []
    
    
    private var _cost:Int?
    var cost:Int{
        get { return _cost ?? 0 }
        set { _cost = newValue }
    }
    var _reward:Int?
    var reward:Int{
        get { return _reward ?? 50}
        set { _reward = newValue }
    }
    
    var notes:String?
    var image:String?
    var video:String?
    
    
    enum CodingKeys:String, CodingKey {
        case id
        case name
        case cards
        case _reward = "reward"
        case _cost = "cost"
        case notes
        case image
        case video
    }
    
    init(withName name:String) {
        self.id = UUID().uuidString
        self.name = name
        self.cost = 0
    }
    
}
