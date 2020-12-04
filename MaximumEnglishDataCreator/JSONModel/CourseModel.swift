//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON




class CourseModel: Codable {
    
    
    var id:String
    var name:String
    var lessons:[LessonModel] = []
    var pretest:PretestModel
    var video:String?
    
    private var notes:String?
    
    private var image:String?

    
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
