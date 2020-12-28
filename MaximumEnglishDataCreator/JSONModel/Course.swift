//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON




class Course: Codable {
    
    
    var id:String
    var name:String
    var lessons:[Lesson] = []
    var pretest:Pretest
    var video:String?
    var notes:String?
    var image:String?
    var _reward:Int?
        var reward:Int{
            get { return _reward ?? 100}
            set { _reward = newValue }
        }

    
    enum CodingKeys:String, CodingKey {
        case id
        case name
        case lessons
        case pretest
        case notes
        case image
        case video
        case _reward = "reward"
    }
    
    init(withName name:String) {
        self.id = UUID().uuidString
        self.name = name
        self.pretest = Pretest()
    }
    
}
