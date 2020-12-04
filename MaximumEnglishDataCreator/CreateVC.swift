//
//  CreateVC.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 2019/10/20.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON

class CreateVC: NSViewController, DropViewDelegate, NSTextFieldDelegate {

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
    @IBOutlet weak var costField: NSTextField!
    
    
//    var jsonManager:JSONManager!
    var jsonModel:JSONModel!
    
    var selectedCourse:CourseModel? {
        let index = self.levelSelector.indexOfSelectedItem
        guard index >= 0, index < self.jsonModel.courses.count else {return nil}
        return self.jsonModel.courses[index]
    }
    
    
    var selectedLesson:LessonModel? {
        
        let index =  self.lessonSelector.indexOfSelectedItem
        
        guard let course = self.selectedCourse, index >= 0, index < course.lessons.count else {return nil}
        
        return course.lessons[index]
        
    }
    
    var lessons:[LessonModel] { return self.selectedCourse?.lessons ?? [] }
    
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
        self.costField.delegate = self
        self.setLevelPicker()
    }
    
    func toggleButtons() {
        
        self.vocabDropView.isEnabled = self.levelSelector.numberOfItems > 0
        self.grammarDropView.isEnabled = self.levelSelector.numberOfItems > 0
        self.lessonRemoveButton.isEnabled = self.selectedLesson != nil
        self.lessonAddButton.isEnabled = self.selectedCourse != nil
        
        self.levelUpButton.isEnabled = self.selectedCourse != nil
        self.levelDownButton.isEnabled = self.selectedCourse != nil
        self.levelRemoveButton.isEnabled = self.selectedCourse != nil
        
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
        for course in self.jsonModel.courses { self.levelSelector.addItem(withTitle: course.name) }
        
        self.levelSelector.selectItem(at: index)
        
        self.setLessonPicker()
        
    }

    
    
    func setLessonPicker(selectIndex index:Int = 0) {
        self.lessonSelector.removeAllItems()
        
        guard let course = self.selectedCourse else { return }
        
        for lesson in course.lessons { self.lessonSelector.addItem(withTitle: lesson.name) }
        
        self.lessonSelector.addItem(withTitle: "Pretest")
        
        self.lessonSelector.selectItem(at: index)
        
        self.reloadAll()
    }
    
    func reloadAll() {
        self.vocabTable.reloadData()
        self.grammarTable.reloadData()
        
        self.costField.stringValue = "\(self.selectedLesson?.cost ?? 0)"
        
        self.toggleButtons()
    }
    
    @IBAction func costEntered(_ sender: Any) {
        guard let lesson = self.selectedLesson else {return}
        print("adding cost")
        lesson.cost = Int(self.costField.intValue)
        print(lesson.cost)
        self.markChanged()
    }
    
   
    
    @IBAction func didChangeSelection(_ sender: NSPopUpButton) {
        if sender == self.levelSelector {
            self.setLessonPicker()
        } else {
            self.reloadAll()
            
        }
        self.toggleButtons()
    }
    
    @IBAction func addLevelPressed(_ sender: NSButton) {
        
        guard let name = self.getNewLevelName() else {return}
         
        self.jsonModel.courses.append(CourseModel(withName: name))
         
         self.setLevelPicker(selectIndex: self.jsonModel.courses.count - 1)
        
        self.markChanged()
        
    }
    
    
    @IBAction func addLessonPressed(_ sender: NSButton) {
        
        guard let course = self.selectedCourse, let name = self.getNewLessonName() else {return}
        
        course.lessons.append(LessonModel(withName: name))
         
        self.setLessonPicker(selectIndex:self.lessonSelector.numberOfItems - 1)
        
        self.markChanged()
    }

    @IBAction func removeLessonPressed(_ sender: Any) {
        
        guard let course = self.selectedCourse, self.selectedLesson != nil else { return }
        if Alert.PresentConfirmationAlert(text: "Are you sure you want to delete this Lesson?") {
            
            
            course.lessons.remove(at: self.lessonSelector.indexOfSelectedItem)
        
            self.setLessonPicker()
            self.markChanged()
        }
    }
    
    @IBAction func removeLevelPressed(_ sender: Any) {
        guard self.selectedCourse != nil else { return }
        if Alert.PresentConfirmationAlert(text: "Are you sure you want to delete this Level? All lessons and cards will also be deleted!!!") {
            
            jsonModel.courses.remove(at: self.levelSelector.indexOfSelectedItem)
            
            self.setLevelPicker()
            self.markChanged()
        }
    }
    
    @IBAction func lessonChangePressed(_ sender: NSButton) {
        
        guard let course = self.selectedCourse, self.selectedLesson != nil else { return }
        
        let amount = sender.tag - 1
        
        let (adjustedArray, newIndex) = course.lessons.changingItemPosition(atIndex: self.lessonSelector.indexOfSelectedItem, by: amount)
        
        course.lessons = adjustedArray
        
        self.setLessonPicker(selectIndex: newIndex)
        self.markChanged()
    }
    
    @IBAction func levelChangePressed(_ sender: NSButton) {
           
           guard self.selectedCourse != nil else { return }
           
           let amount = sender.tag - 1
           
        let (adjustedArray, newIndex) = self.jsonModel.courses.changingItemPosition(atIndex: self.levelSelector.indexOfSelectedItem, by: amount)
        self.jsonModel.courses = adjustedArray
           
           self.setLevelPicker(selectIndex: newIndex)
           self.markChanged()
       }
    
    @IBAction func renameLevelPressed(_ sender: Any) {
        guard let course = self.selectedCourse, let name = self.getNewLevelName(rename: course.name) else {return}
        
        course.name = name
        
        let lessonIndex = self.lessonSelector.indexOfSelectedItem
        self.setLevelPicker(selectIndex:self.levelSelector.indexOfSelectedItem )
        self.setLessonPicker(selectIndex: lessonIndex)
        self.markChanged()
 
    }
    
       @IBAction func renameLessonPressed(_ sender: Any) {
       
        guard let lesson = self.selectedLesson, let name = self.getNewLessonName(rename: lesson.name) else { return }
           
        lesson.name = name
           
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
        return self.getUniqueName(nameList: self.jsonModel.courses.map({$0.name}), placeholderName: rename ?? "Course - \(self.jsonModel.courses.count + 1)")
    }
    
    func getNewLessonName(rename:String? = nil)->String? {
        return self.getUniqueName(nameList: self.lessons.map({$0.name}), placeholderName: rename ?? "Lesson - \(self.lessons.count + 1)")
    }
   
    func changeLessonNotes(to newText:String) {
        
        guard let lesson = self.selectedLesson else { return }
        
        lesson.notes = newText
        
        self.markChanged()
        
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
        
        if row < 0 { return }
        
        guard let card = self.card(ofType: isVocab ? .vocab : .grammar, atIndex: row) else {return}
        
        card.includedInFinal = sender.state == .on
        
        
//        self.jsonManager.editCard(ofType: type.stringValue(), atIndex: row, inLessonAtIndex: self.lessonSelector.indexOfSelectedItem, inLevelAtIndex: self.levelSelector.indexOfSelectedItem, newValue: sender.state == .on, forProperty: JSONKey.includedInFinal.keyValue())
//
        self.changed = true
        self.toggleButtons()
//
    }
    
    func card(ofType type:CardType, atIndex index: Int) -> CardModel? {
        
        guard index >= 0 else {return nil}
        
        let cards = self.cardsForSelected(ofType: type)
        
        guard index < cards.count else {return nil}
        
        return cards[index]
        
    }
    
    func cardsForSelected(ofType type:CardType)-> [CardModel] {
        guard let course = self.selectedCourse else {return []}
        return (type == .vocab ? selectedLesson?.vocabulary : selectedLesson?.grammar) ?? (type == .vocab ? course.pretest.vocabulary : course.pretest.grammar)
    }
    
    
//    func didGetURL(url: URL, dropView: DropView) {
//
//
//        guard self.selectedLevel != nil else {
//            dropView.displayText = "Drag File Here"
//            return
//        }
//
//        guard let text = try? String(contentsOf: url) else {
//            dropView.displayText = "cannot read url"
//            return
//        }
//
//        var cards = [JSON]()
//
//        let rows = text.components(separatedBy: "\n")
//        for row in rows {
//            var dic = [String:Any]()
//            let values = row.components(separatedBy: ",")
//
//            guard values.count >= 2, values[0].trimmingCharacters(in: .whitespacesAndNewlines) != "", values[1].trimmingCharacters(in: .whitespacesAndNewlines) != "" else {continue}
//
//
//            dic[JSONKey.question.keyValue()] = values[0].replacingOccurrences(of: "\r", with: "")
//            dic[JSONKey.answer.keyValue()] = values[1].replacingOccurrences(of: "\r", with: "")
//
//            if values.count > 2 { dic[JSONKey.notes.keyValue()] = values[2] }
//
//            if values.count > 3 { dic[JSONKey.alternateAnswers.keyValue()] = values[3].replacingOccurrences(of: "\r", with: "").components(separatedBy: "|") }
//
//            cards.append(JSON(dic))
//
//        }
//
//        if cards.count < 0 { return }
//
//        let type = dropView == self.vocabDropView ? JSONKey.vocabularyCards.keyValue() : JSONKey.grammarCards.keyValue()
//
//        jsonManager.setCards(cards, ofType: type, forLessonAtIndex: self.lessonSelector.indexOfSelectedItem, inLevelAtIndex: self.levelSelector.indexOfSelectedItem)
//
//        self.markChanged()
//        self.vocabTable.reloadData()
//        self.grammarTable.reloadData()
//    }
//
    
    
    
    @IBAction func savePressed(_ sender: Any) {
        
        do {
            try self.jsonModel.save()
            self.changed = false
            self.toggleButtons()
        } catch {
            Alert.PresentErrorAlert(text: error.localizedDescription)
        }
        
        
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
        
        guard let card = self.card(ofType: type, atIndex: row), column >= 0, column < ColumnType.allCases.count else {
            print("something messed up \(row) \(column)")
            return }
        
        var newValue = sender.stringValue
        
        switch ColumnType.allCases[column] {
        
        case .question:
            card.question = newValue
        case .answer:
            card.answer = newValue
        case .notes:
            card.notes = newValue
        case .alternatives:
            let separators = [",  ", ", ", ","]
            let arrayValue = separators.reduce([newValue]) { (comps, separator) in
                return comps.flatMap { return $0.components(separatedBy: separator) }.filter({return !$0.isEmpty})
            }
            card.alternates = arrayValue
            
        case .displayAnswer:
            
            card.displayAnswer = newValue
            
        }

        self.changed = true
        self.toggleButtons()
        
    }
    
    
}

extension CreateVC:NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        let type:CardType = tableView == self.vocabTable ? .vocab : .grammar
        return self.cardsForSelected(ofType: type).count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cardType:CardType = tableView == self.vocabTable ? .vocab : .grammar
        
        guard let card = self.card(ofType: cardType, atIndex: row) else {return nil}
        
        
        if tableColumn!.identifier.rawValue == "final" {
            if self.selectedLesson != nil {
                let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! CheckCell
                
                cell.checkBox.state = card.includedInFinal ? .on : .off
                
                return cell
                
            } else {
                
                return NSView()
            }
        }
        
        let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        var cellText = ""
        
        switch ColumnType(rawValue: tableColumn!.identifier.rawValue)! {
        
        case .question:
            cellText = card.question
        case .answer:
            cellText = card.answer
        case .notes:
            cellText = card.notes
        case .alternatives:
            cellText = card.alternates.joined(separator: ",")
        case .displayAnswer:
            cellText = card.displayAnswer
        }
        
        cell.textField?.stringValue = cellText
        
        
        
        return cell
    }
    
}

extension CreateVC:NSTextViewDelegate {
    
    func textDidEndEditing(_ notification: Notification) {
        
        guard let textField = notification.object as? NSTextField else { return }
        
        self.changeLessonNotes(to: textField.stringValue)
    }
    
}

extension Array {
    func changingItemPosition(atIndex index:Int, by amount:Int)-> ([Element], Int){
        var newArray = self
        guard index + amount >= 0 && index + amount < newArray.count else { return (newArray, index)}
        let newIndex = index + amount
        let level = newArray.remove(at: index)
        newArray.insert(level, at: newIndex)
        return (newArray, newIndex)
    }
}
