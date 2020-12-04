//
//  ViewController.swift
//  MaximumEnglishDataCreator
//
//  Created by Dylan Southard on 2019/10/19.
//  Copyright © 2019 Dylan Southard. All rights reserved.
//

import Cocoa
import SwiftyJSON

class StartVC: NSViewController, DropViewDelegate {

    @IBOutlet weak var dropView: FileDropView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dropView.delegate = self
        self.dropView.expectedExt = ["json"]
        self.dropView.displayText = "Drop JSON file here"
    }
    
    
    
    func didGetURL(url: URL, dropView: DropView) {
        
        if let jsonModel = JSONModel.fromURL(url: url) {
            self.presentCreateVC(withModel: jsonModel)
        }
        
//        self.presentCreateVC(withURL:url)
        
    }
    
    @IBAction func createNewPressed(_ sender: Any) {
        self.presentCreateVC(withModel:JSONModel())
    }
    
    
    
    func presentCreateVC(withModel model:JSONModel) {
        
        let vc = NSStoryboard(name:"Main", bundle: nil).instantiateController(withIdentifier: "create") as! CreateVC
        vc.jsonModel = model
        self.presentAsSheet(vc)
    }
    
    


}

