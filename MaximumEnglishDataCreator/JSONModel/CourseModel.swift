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
    
    
    let id:String
    let name:String
    let lessons:[Lesson] = []
    let pretest:Pretest
    let video:String?
    let notes:String?
    let image:String?

    
    enum CodingKeys:String, CodingKey {
        case id
        case name
        case lessons
        case pretest
        case notes
        case image
        case video
    }
    
    init(withName name:String) {
        self.id = UUID().uuidString
        self.name = name
        self.pretest = PretestModel()
    }
    
}
