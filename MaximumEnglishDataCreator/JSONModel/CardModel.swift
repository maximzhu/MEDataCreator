//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON

enum CardType {

case vocab
case grammar

func stringValue()->String {
    switch self {
    case .vocab:
        return JSONKey.vocabularyCards.keyValue()
    case .grammar:
        return JSONKey.grammarCards.keyValue()
        
    }
}
}


class CardModel: Codable {
    
    
    private var _id:String?
    var id:String {
        get { return _id ?? UUID().uuidString}
        set { _id = newValue }
    }
    var question:String
    var answer:String
    
    private var _alternates:[String]?
    var alternates:[String]{
        get { return _alternates ?? [] }
        set { _alternates = newValue }
    }
    
    private var _notes:String?
    var notes:String {
        get { return _notes ?? "" }
        set { _notes = newValue }
    }
    
    private var _includedInFinal:Bool?
    var includedInFinal:Bool {
        get { return _includedInFinal ?? true }
        set { _includedInFinal = newValue }
    }
    
    private var _displayAnswer:String?
    var displayAnswer:String {
        get { return _displayAnswer ?? "" }
        set { _displayAnswer = newValue }
    }
    
    enum CodingKeys:String, CodingKey {
        case _id = "id"
        case question
        case answer
        case _notes = "notes"
        case _includedInFinal = "includeInFinal"
        case _displayAnswer = "display_answer"
    }
    
    func setID(){ _id = id }
}
