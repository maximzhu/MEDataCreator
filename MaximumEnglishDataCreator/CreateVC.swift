//
//  CreateVC.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 2019/10/20.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON

class CreateVC: NSViewController, DropViewDelegate {

    @IBOutlet weak var vocabDropView: FileDropView!
    @IBOutlet weak var grammarDropView: FileDropView!
    @IBOutlet weak var vocabTable: NSTableView!
    @IBOutlet weak var grammarTable: NSTableView!
    @IBOutlet weak var levelSelector: NSPopUpButton!
    @IBOutlet weak var lessonSelector: NSPopUpButton!
    @IBOutlet weak var lessonUpButton: NSButton!
    @IBOutlet weak var lessonDownButton: NSButton!
    @IBOutlet weak var lessonAddButton: NSButton!
    @IBOutlet weak var lessonRemoveButton: NSButton!
    
    @IBOutlet weak var levelUpButton: NSButton!
    @IBOutlet weak var levelDownButton: NSButton!
    @IBOutlet weak var levelAddButton: NSButton!
    @IBOutlet weak var levelRemoveButton: NSButton!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet var notesField: NSTextView!
    
    
    var jsonManager:JSONManager!
    
    var selectedLevel:JSON? {
        let index = self.levelSelector.indexOfSelectedItem
        guard index >= 0, index < self.jsonManager.levels.count else {return nil}
        return self.jsonManager.levels[index]
        
    }
    
    var selectedLevelID:String? {
        let index = self.levelSelector.indexOfSelectedItem
        guard self.jsonManager.levels.count > index else {return nil}
        
        return self.jsonManager.levels[index][JSONKey.levelID.keyValue()].stringValue
       
        
    }
    
    var selectedLesson:JSON? {
        let index =  self.lessonSelector.indexOfSelectedItem
        guard let level = self.selectedLevel, index >= 0, index < self.jsonManager.lessons(forLevel: level).count, self.jsonManager.lessons(forLevel: level).count > self.lessonSelector.indexOfSelectedItem else {return nil}
        
        return self.jsonManager.lessons(forLevel: level)[self.lessonSelector.indexOfSelectedItem]
        
    }
    
    var lessons:[JSON] {
        
        guard self.selectedLevel != nil else {return [JSON]()}
        return self.jsonManager.lessons(forLevel: self.jsonManager.levels[self.levelSelector.indexOfSelectedItem])
        
    }
    
    var changed = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.vocabDropView.delegate = self
        self.grammarDropView.delegate = self
        self.vocabTable.delegate = self
        self.vocabTable.dataSource = self
        self.grammarTable.delegate = self
        self.grammarTable.dataSource = self
        self.notesField.delegate = self
        self.setLevelPicker()
    }
    
    func toggleButtons() {
        
        self.vocabDropView.isEnabled = self.levelSelector.numberOfItems > 0
        self.grammarDropView.isEnabled = self.levelSelector.numberOfItems > 0
        self.lessonRemoveButton.isEnabled = self.selectedLesson != nil
        self.lessonAddButton.isEnabled = self.selectedLevel != nil
        
        self.levelUpButton.isEnabled = self.selectedLevel != nil
        self.levelDownButton.isEnabled = self.selectedLevel != nil
        self.levelRemoveButton.isEnabled = self.selectedLevel != nil
        
        self.lessonUpButton.isEnabled = self.lessonSelector.indexOfSelectedItem < self.lessonSelector.numberOfItems - 2
        self.lessonDownButton.isEnabled = self.lessonSelector.indexOfSelectedItem > 0 && self.lessonSelector.indexOfSelectedItem < self.lessonSelector.numberOfItems - 1
        
        self.saveButton.isEnabled = self.changed
        self.notesField.isEditable = self.selectedLesson != nil
    }
    
    func markChanged(){
        self.changed = true
        self.toggleButtons()
    }
    
    
    func setLevelPicker(selectIndex index:Int = 0) {
        
        self.levelSelector.removeAllItems()
        for level in self.jsonManager.levels {
            
            self.levelSelector.addItem(withTitle: level[JSONKey.levelName.keyValue()].stringValue)
            
        }
        
        
        self.levelSelector.selectItem(at: index)
        
        self.setLessonPicker()
        
    }

    
    
    func setLessonPicker(selectIndex index:Int = 0) {
        self.lessonSelector.removeAllItems()
        
        guard let level = self.selectedLevel else { return }
        
        for item in self.jsonManager.lessons(forLevel: level) {
            self.lessonSelector.addItem(withTitle: item[JSONKey.lessonName.keyValue()].string ?? "no name")
        }
        
        self.lessonSelector.addItem(withTitle: "Pretest")
        
        self.lessonSelector.selectItem(at: index)
        
        self.reloadAll()
    }
    
    func reloadAll() {
        self.vocabTable.reloadData()
        self.grammarTable.reloadData()
        self.toggleButtons()
    }
    
    @IBAction func didChangeSelection(_ sender: NSPopUpButton) {
        if sender == self.levelSelector {
            self.setLessonPicker()
        } else {
            self.vocabTable.reloadData()
            self.grammarTable.reloadData()
        }
        self.toggleButtons()
    }
    
    @IBAction func addLevelPressed(_ sender: NSButton) {
        
        guard let name = self.getNewLevelName() else {return}
        
        var _levels = self.jsonManager.levels
         
         let newLevel = JSON([JSONKey.levelID.keyValue():UUID().uuidString, JSONKey.levelName.keyValue():name])
         
         _levels.append(newLevel)
         
         self.jsonManager.setLevels(_levels)
        
         self.setLevelPicker(selectIndex: self.jsonManager.levels.count - 1)
        
        self.markChanged()
        
    }
    
    
    @IBAction func addLessonPressed(_ sender: NSButton) {
        
        guard let name = self.getNewLessonName() else {return}
        
        var _lessons = self.lessons
         
        let newLesson:JSON = [JSONKey.lessonID.keyValue():"\(UUID().uuidString)", JSONKey.lessonName.keyValue():name, JSONKey.vocabularyCards.keyValue():[JSON](), JSONKey.grammarCards.keyValue():[JSON]()]
         
        _lessons.append(newLesson)
         
         self.jsonManager.setLessons(_lessons, forLevelAtIndex: self.levelSelector.indexOfSelectedItem)
        self.setLessonPicker(selectIndex:self.lessonSelector.numberOfItems - 1)
        
        self.markChanged()
    }

    @IBAction func removeLessonPressed(_ sender: Any) {
        
        guard self.selectedLesson != nil else { return }
        if Alert.PresentConfirmationAlert(text: "Are you sure you want to delete this Lesson?") {
            
            var lessons = self.lessons
            lessons.remove(at: self.lessonSelector.indexOfSelectedItem)
            
            self.jsonManager.setLessons(lessons, forLevelAtIndex: self.levelSelector.indexOfSelectedItem)
            
            self.setLessonPicker()
            self.markChanged()
        }
    }
    
    @IBAction func removeLevelPressed(_ sender: Any) {
        guard self.selectedLevel != nil else { return }
        if Alert.PresentConfirmationAlert(text: "Are you sure you want to delete this Level? All lessons and cards will also be deleted!!!") {
            
            var _levels = jsonManager.levels
            _levels.remove(at: self.levelSelector.indexOfSelectedItem)
            
            self.jsonManager.setLevels(_levels)
            
            self.setLevelPicker()
            self.markChanged()
        }
    }
    
    @IBAction func lessonChangePressed(_ sender: NSButton) {
        
        guard self.selectedLesson != nil else { return }
        
        let amount = sender.tag - 1
        
        let (adjustedArray, newIndex) = self.arrayChangingItemPosition(atIndex: self.lessonSelector.indexOfSelectedItem, inArray: self.jsonManager.lessons(forLevel: self.selectedLevel!), by: amount)
        self.jsonManager.setLessons(adjustedArray, forLevelAtIndex: self.levelSelector.indexOfSelectedItem)
        
        self.setLessonPicker(selectIndex: newIndex)
        self.markChanged()
    }
    
    @IBAction func levelChangePressed(_ sender: NSButton) {
           
           guard self.selectedLevel != nil else { return }
           
           let amount = sender.tag - 1
           
           let (adjustedArray, newIndex) = self.arrayChangingItemPosition(atIndex: self.levelSelector.indexOfSelectedItem, inArray: self.jsonManager.levels, by: amount)
           self.jsonManager.setLevels(adjustedArray)
           
           self.setLevelPicker(selectIndex: newIndex)
           self.markChanged()
       }
    
    @IBAction func renameLevelPressed(_ sender: Any) {
        guard self.selectedLevel != nil, let name = self.getNewLevelName(rename: self.selectedLevel![JSONKey.levelName.keyValue()].string) else {return}
        
        var _levels = self.jsonManager.levels
        _levels[self.levelSelector.indexOfSelectedItem][JSONKey.levelName.keyValue()] = JSON(name)
        
        let lessonIndex = self.lessonSelector.indexOfSelectedItem
        self.jsonManager.setLevels(_levels)
        self.setLevelPicker(selectIndex:self.levelSelector.indexOfSelectedItem )
        self.setLessonPicker(selectIndex: lessonIndex)
        self.markChanged()
 
    }
    
       @IBAction func renameLessonPressed(_ sender: Any) {
        print("renaming")
           guard self.selectedLesson != nil, let name = self.getNewLevelName(rename: self.selectedLesson![JSONKey.lessonName.keyValue()].string) else {
            print("not gonna do it")
            return
            
        }
           
        var _lessons = self.lessons
        
           _lessons[self.lessonSelector.indexOfSelectedItem][JSONKey.lessonName.keyValue()] = JSON(name)
           
        self.jsonManager.setLessons(_lessons, forLevelAtIndex: self.levelSelector.indexOfSelectedItem)
           self.setLessonPicker(selectIndex:self.lessonSelector.indexOfSelectedItem )
           
           self.markChanged()
    
       }
    
    func getUniqueName(nameList:[String], placeholderName:String, message:String = "Please choose a name")->String? {
        
        guard let name = Alert.GetUserInput(message: message, placeholderText: "\(placeholderName)") else {return nil}
        
        if name == "" || nameList.contains(name) {
            return getUniqueName(nameList: nameList, placeholderName: placeholderName, message: "Please choose UNIQUE non-blank name")
        }
        
        return name
    }
    
    func getNewLevelName(rename:String? = nil)-> String? {
        return self.getUniqueName(nameList: self.jsonManager.levels.map({$0[JSONKey.levelName.keyValue()].stringValue}), placeholderName: rename ?? "Course - \(self.jsonManager.levels.count + 1)")
    }
    
    func getNewLessonName(rename:String? = nil)->String? {
        return self.getUniqueName(nameList: self.lessons.map({$0[JSONKey.lessonName.keyValue()].stringValue}), placeholderName: rename ?? "Lesson - \(self.lessons.count + 1)")
    }
   
    func changeLessonNotes(to newText:String) {
        
        guard self.selectedLesson != nil else { return }
        
        self.jsonManager.setNotes(newText, forLessonAtIndex: self.lessonSelector.indexOfSelectedItem, inLevelAtIndex: self.levelSelector.indexOfSelectedItem)
        
    }
    
    
    func arrayChangingItemPosition(atIndex index:Int, inArray array:[JSON], by amount:Int)-> ([JSON], Int){
        var newArray = array
        guard index + amount >= 0 && index + amount < newArray.count else { return (newArray, index)}
        let newIndex = index + amount
        let level = newArray.remove(at: index)
        newArray.insert(level, at: newIndex)
        return (newArray, newIndex)
    }
    

    @IBAction func checkBoxChecked(_ sender: NSButton) {
        
        let isVocab = self.vocabTable.row(for: sender) >= 0
        
        let row = isVocab ? self.vocabTable.row(for: sender) : self.grammarTable.row(for: sender)
        let type:CardType = isVocab ? .vocab : .grammar
        
        if row < 0 { return }
        
        self.jsonManager.editCard(ofType: type.stringValue(), atIndex: row, inLessonAtIndex: self.lessonSelector.indexOfSelectedItem, inLevelAtIndex: self.levelSelector.indexOfSelectedItem, newValue: sender.state == .on, forProperty: JSONKey.includedInFinal.keyValue())

        self.changed = true
        self.toggleButtons()
        
    }
    
    
    func didGetURL(url: URL, dropView: DropView) {
        
        
        guard self.selectedLevel != nil else {
            dropView.displayText = "Drag File Here"
            return
        }
        
        guard let text = try? String(contentsOf: url) else {
            dropView.displayText = "cannot read url"
            return
        }
        
        var cards = [JSON]()
        
        let rows = text.components(separatedBy: "\n")
        for row in rows {
            var dic = [String:Any]()
            let values = row.components(separatedBy: ",")
            
            guard values.count >= 2, values[0].trimmingCharacters(in: .whitespacesAndNewlines) != "", values[1].trimmingCharacters(in: .whitespacesAndNewlines) != "" else {continue}
            
            
            dic[JSONKey.question.keyValue()] = values[0].replacingOccurrences(of: "\r", with: "")
            dic[JSONKey.answer.keyValue()] = values[1].replacingOccurrences(of: "\r", with: "")
            
            if values.count > 2 { dic[JSONKey.notes.keyValue()] = values[2] }
            
            if values.count > 3 { dic[JSONKey.alternateAnswers.keyValue()] = values[3].replacingOccurrences(of: "\r", with: "").components(separatedBy: "|") }
            
            cards.append(JSON(dic))
            
        }
        
        if cards.count < 0 { return }
        
        let type = dropView == self.vocabDropView ? JSONKey.vocabularyCards.keyValue() : JSONKey.grammarCards.keyValue()
        
        jsonManager.setCards(cards, ofType: type, forLessonAtIndex: self.lessonSelector.indexOfSelectedItem, inLevelAtIndex: self.levelSelector.indexOfSelectedItem)
        
        self.markChanged()
        self.vocabTable.reloadData()
        self.grammarTable.reloadData()
    }
    
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        self.jsonManager.json[JSONKey.jsonID.keyValue()] = JSON("\(Date().timeIntervalSince1970)")
        self.jsonManager.writeFile()
        
        self.changed = false
        self.toggleButtons()
    }
    
    
    @IBAction func cancelPressed(_ sender: Any) {
        
        self.dismiss(self)
    }
    
    
    @IBAction func tableViewTextChanged(_ sender: NSTextField) {
        var type:CardType = .vocab
        var row = self.vocabTable.row(for: sender)
        var column = self.vocabTable.column(for: sender)
        
        
        if row < 0 {
            type = .grammar
            row = self.grammarTable.row(for: sender)
            column = self.grammarTable.column(for: sender)
        }
        
        guard row >= 0 && column >= 0, column < ColumnType.allCases.count else {
            print("something messed up \(row) \(column)")
            return }
        
        let property = ColumnType.allCases[column].stringValue()
        
        
        var newValue:Any = sender.stringValue
        
        if property == ColumnType.alternatives.stringValue() {
            
            let separators = [",  ", ", ", ","]
            newValue = separators.reduce([sender.stringValue]) { (comps, separator) in
                return comps.flatMap { return $0.components(separatedBy: separator) }.filter({return !$0.isEmpty})
            }
        }
            
//            snewValue = sender.stringValue.components(separatedBy: ",")}
        
        
        self.jsonManager.editCard(ofType: type.stringValue(), atIndex: row, inLessonAtIndex: self.lessonSelector.indexOfSelectedItem, inLevelAtIndex: self.levelSelector.indexOfSelectedItem, newValue: newValue, forProperty: property)
        
        self.changed = true
        self.toggleButtons()
        
    }
    
    
}

extension CreateVC:NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let level = self.selectedLevel else {return 0}
        let lesson = self.selectedLesson ?? self.jsonManager.pretest(forLevel: level)
        let cardType = tableView == self.vocabTable ? JSONKey.vocabularyCards.keyValue():JSONKey.grammarCards.keyValue()
       
        return lesson[cardType].arrayValue.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let level = self.selectedLevel else {return nil}
        let lesson = self.selectedLesson ?? self.jsonManager.pretest(forLevel: level)
        let cardType = tableView == self.vocabTable ? JSONKey.vocabularyCards.keyValue():JSONKey.grammarCards.keyValue()
        
        let card = lesson[cardType].arrayValue[row]
        
        
        if tableColumn!.identifier.rawValue == "final" {
            if self.selectedLesson != nil {
                let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! CheckCell
                
                if let include = card[JSONKey.includedInFinal.keyValue()].bool, include == false {
                    cell.checkBox.state = .off
                } else {
                    cell.checkBox.state = .on
                }
                
                return cell
                
            } else {
                
                return NSView()
            }
        }
        
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        if tableColumn!.identifier.rawValue == "alternate" {
           
            let list  = card[JSONKey.alternateAnswers.keyValue()].arrayValue.map {$0.stringValue}
            cell.textField?.stringValue = list.joined(separator: ",")
                
        } else {
            let field = tableColumn!.identifier.rawValue.lowercased()
             cell.textField?.stringValue = card[field].stringValue
        }
        
        
        
        return cell
    }
    
}

extension CreateVC:NSTextViewDelegate {
    
    func textDidEndEditing(_ notification: Notification) {
        
        guard let textField = notification.object as? NSTextField else { return }
        
        self.changeLessonNotes(to: textField.stringValue)
    }
    
}
