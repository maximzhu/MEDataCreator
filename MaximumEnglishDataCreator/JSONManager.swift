//
//  LibraryCatalogManager.swift
//  FilmManager
//
//  Created by Dylan Southard on 2019/07/11.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON




//MARK: - =============== KEYS ===============
enum JSONKey {
    
    case jsonID
    case levels
    case lessons
    case levelID
    case lessonID
    case levelName
    case pretestID
    case lessonName
    case vocabularyCards
    case grammarCards
    case cardID
    case question
    case answer
    case notes
    case includedInFinal
    case pretest
    case alternateAnswers
    case displayAnswer
    
    func keyValue()->String {
        
        switch self {
            
        case .jsonID, .lessonID, .pretestID:
            return "id"
        case .levels:
            return "levels"
        case .lessons:
            return "lessons"
        case .levelName, .lessonName:
            return "name"
        case .vocabularyCards:
            return "vocabulary"
        case .grammarCards:
            return "grammar"
        case .cardID, .question:
            return "question"
        case .answer:
            return "answer"
        case .notes:
            return "notes"
        case .includedInFinal:
            return "includeInFinal"
        case .pretest:
            return "pretest"
            case .alternateAnswers:
            return "alternate"
        case .displayAnswer:
            return "display_answer"
        case .levelID:
            return "level_id"
        }
    
    }
}

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

class JSONManager: NSObject {
    
    var json:JSON
    
    var jsonURL:URL?
    
    init(jsonURL:URL?) {
        
        
        if let url = jsonURL, let data = try? Data(contentsOf: url), let realJSON = try? JSON(data: data), realJSON[JSONKey.levels.keyValue()].array != nil {
            
            self.jsonURL = url
            self.json = realJSON
            
        } else {
            
            self.json = JSON()
            
        }
        
        super.init()
        
        self.populateLevels()
        
    }
    
    func populateLevels() {
        
        var _levels = self.levels
        
        for (i, level) in _levels.enumerated() {
            
            if self.pretest(forLevel: _levels[i]).isEmpty {
                _levels[i][JSONKey.pretest.keyValue()] = [JSONKey.pretestID.keyValue():UUID().uuidString,  JSONKey.vocabularyCards.keyValue():[JSON](), JSONKey.grammarCards.keyValue():[JSON]()]
            }
            
            let currentLevelID = level[JSONKey.levelID.keyValue()].string
            
            if currentLevelID == nil || currentLevelID! == level[JSONKey.levelName.keyValue()].stringValue {
                _levels[i][JSONKey.levelID.keyValue()] = JSON(UUID().uuidString)
            }
            _levels.append(level)
        }
        
//        for levelName in LevelName.allCases {
//
//            var level:JSON!
//
//            if levelNames.contains(levelName.rawValue) {
//                level = self.levels[levelNames.firstIndex(of: levelName.rawValue)!]
//
//            } else {
//                level = JSON([JSONKey.levelID.keyValue():JSON(levelName.rawValue)])
//
//            }
//
//            //check for pretest
//
//
//
//
//        }
        
        self.json[JSONKey.levels.keyValue()] = JSON(_levels)
        
    }
    
    func setLevels(_ levels:[JSON]) { self.json[JSONKey.levels.keyValue()] = JSON(levels) }
    
   
    func setLessons(_ lessons:[JSON], forLevelAtIndex index:Int) {
        
        guard self.levels.count > index else {
            print("levels less \(self.levels.count) vs \(index)")
            return
            
        }
        
        self.json[JSONKey.levels.keyValue()][index][JSONKey.lessons.keyValue()] = JSON(lessons)
        
    }
    
    func setPretest(_ pretest:JSON, forLevelAtIndex index:Int) {
        
        guard self.levels.count > index else { return }
        
        self.json[JSONKey.levels.keyValue()][index][JSONKey.pretest.keyValue()] = JSON(pretest)
        
    }
    
    func setNotes(_ notes:String, forLessonAtIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int) {
        
        guard self.lessonExists(atIndex: lessonIndex, inLevelAtIndex: levelIndex) else { return }
        
        self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.lessons.keyValue()][lessonIndex][JSONKey.notes.keyValue()] = JSON(notes)
        
    }
    
    func setCards(_ cards:[JSON], ofType type:String, forLessonAtIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int) {
        
        if self.lessonExists(atIndex: lessonIndex, inLevelAtIndex: levelIndex) {
            
            self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.lessons.keyValue()][lessonIndex][type] = JSON(cards)
            return
            
        }
        
        self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.pretest.keyValue()][type] = JSON(cards)
        
    }
    
    
    
    func editCard(ofType type:String, atIndex cardIndex:Int, inLessonAtIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int, newValue:Any, forProperty property:String) {
        
        // if index is greater than lesson count use pretest
        var cards = self.cardsForLessonOrPretest(ofType: type, atIndex: lessonIndex, inLevelAtIndex: levelIndex).arrayValue
        
        
        if cards.count > cardIndex {
            
            cards[cardIndex][property] = JSON(newValue)
            
        } else {
            
            cards.append(JSON([property:newValue]))
            
        }
        
        self.setCards(cards, ofType: type, forLessonAtIndex: lessonIndex, inLevelAtIndex: levelIndex)
        
    }
    
    func lessonExists(atIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int)-> Bool {
        
        return self.levels.count > levelIndex && self.lessons(forLevel: self.levels[levelIndex]).count > lessonIndex
    }
    
    func cardsForLessonOrPretest(ofType type: String, atIndex lessonIndex:Int, inLevelAtIndex levelIndex:Int)->JSON {
        return self.lessonExists(atIndex: lessonIndex, inLevelAtIndex: levelIndex) ? self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.lessons.keyValue()][lessonIndex][type] : self.json[JSONKey.levels.keyValue()][levelIndex][JSONKey.pretest.keyValue()][type]
    }

    
    var levels:[JSON] { return self.json[JSONKey.levels.keyValue()].arrayValue }
    
    func lessons(forLevel level:JSON)-> [JSON] { return level[JSONKey.lessons.keyValue()].arrayValue }
    
    func pretest(forLevel level:JSON)-> JSON { return level[JSONKey.pretest.keyValue()] }
    
    func vocabulary(forLesson lesson:JSON)->[JSON] { return lesson[JSONKey.vocabularyCards.keyValue()].arrayValue }
    
    func grammar(forLesson lesson:JSON)->[JSON] { return lesson[JSONKey.grammarCards.keyValue()].arrayValue }
    

    func writeFile() {
        var fileURL = self.jsonURL
        if fileURL == nil {
            var count = 1
            let originalFileName = "MEJSONData"
            var newURL = Prefs.DefaultFolder.appendingPathComponent(originalFileName + ".json")
            while newURL.fileExists {
                let newName = originalFileName + "-" + String(format: "%2d", count)
                newURL = Prefs.DefaultFolder.appendingPathComponent(newName + ".json")
                count += 1
            }
            
            fileURL = newURL
        }
        
        guard let nv = self.json.rawString(), let realURL = fileURL, realURL.isFileURL else {
            
            Alert.PresentErrorAlert(text: "Error updating file")
            
            return
            
        }
        
        FileManager.WriteTextToFile(text: nv, toFolder: realURL.deletingLastPathComponent(), fileName: realURL.lastPathComponent)
        
    }
}
