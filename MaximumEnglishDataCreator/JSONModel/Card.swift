//
//  CardModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON

//enum CardType {
//
//case vocab
//case grammar
//
//func stringValue()->String {
//    switch self {
//    case .vocab:
//        return JSONKey.vocabularyCards.keyValue()
//    case .grammar:
//        return JSONKey.grammarCards.keyValue()
//
//    }
//}
//}


class Card: Codable {
    
    
    var id:String
    var question:String
    var answer:String
    var questionAudio:String?
    var answerAudio:String?
    var notes:String?
    
    private var _alternates:[String]?
    var alternates:[String]{
        get { return _alternates ?? [] }
        set { _alternates = newValue }
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
        case id
        case question
        case answer
        case notes
        case _alternates = "alternate_answers"
        case _includedInFinal = "included_in_final"
        case _displayAnswer = "display_answer"
        case questionAudio = "question_audio"
        case answerAudio = "answer_audio"
    }
    
    init(question:String, answer:String, questionAudio:String? = nil, answerAudio:String? = nil, notes:String? = nil, includedInFinal:Bool? = nil, displayAnswer:String? = nil, alternates:[String]? = nil) {
        self.id = UUID().uuidString
        self.question = question
        self.answer = answer
        self.questionAudio = questionAudio
        self.answerAudio = answerAudio
        self.notes = notes
        self._includedInFinal = includedInFinal
        self._displayAnswer = displayAnswer
        self._alternates = alternates
        
    }
    
    
    
    
}
