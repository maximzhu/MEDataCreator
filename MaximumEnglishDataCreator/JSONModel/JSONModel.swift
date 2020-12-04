//
//  JSONModel.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 12/3/20.
//  Copyright © 2020 Dylan Southard. All rights reserved.
//

import Cocoa


class JSONModel: Codable {
    
    var courses:[CourseModel] = []
    var id:String
    var url:URL?
    
    enum CodingKeys:String, CodingKey {
        case id
        case courses = "levels"
    }
    
    init(){
        self.id = UUID().uuidString
        
    }
    
    static func fromURL( url:URL)-> JSONModel? {
        if let data = try? Data(contentsOf: url) {
        do {
           let json = try JSONDecoder().decode(JSONModel.self, from: data)
            json.url = url
            return json
        } catch {
            Alert.PresentErrorAlert(text: "Error decoding file: " + error.localizedDescription)
            print(error)
        }
        }
        Alert.PresentErrorAlert(text: "Error reading file! No data at path!")
        return nil
    }
    
    func save() throws {
        
        
        self.id = UUID().uuidString
        if self.url == nil {
            var count = 1
            let originalFileName = "MEJSONData"
            var newURL = Prefs.DefaultFolder.appendingPathComponent(originalFileName + ".json")
            while newURL.fileExists {
                let newName = originalFileName + "-" + String(format: "%2d", count)
                newURL = Prefs.DefaultFolder.appendingPathComponent(newName + ".json")
                count += 1
            }
            
            self.url = newURL
        }
        
        guard let realURL = self.url, realURL.isFileURL else {
            throw DisplayableError("Error finding file location!")
        }
        
        do {
            
            let json = try JSONEncoder().encode(self)
            try json.write(to: realURL)
            
        } catch {
            throw DisplayableError("Error writing file!")
        }
        
    }
}


