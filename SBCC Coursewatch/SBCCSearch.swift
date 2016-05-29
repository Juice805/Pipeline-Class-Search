//
//  SBCCSearch.swift
//  SBCC Coursewatch
//
//  Created by Justin Oroz on 5/25/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import Foundation
import hpple

enum urlError: ErrorType {
    case invalidURL
    case noConnection
    case unknownError
}

class SBCCSearch {
    
    private var doc: TFHpple = TFHpple()
    private(set) var terms: [[String: String]] = []
    private(set) var subjects: [[String: String]] = []
    private(set) var instructors: [[String: String]] = []
    private(set) var instructMethods: [[String: String]] = []
    private(set) var levels: [[String: String]] = []
    private(set) var error: urlError? = nil
    
    init(html:String) {
        self.reload(html)
    }
    
    func reload(html:String, parameters: [String:String] = [:]) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: html)!)
        request.HTTPMethod = "POST"
        request.setHTTPBodyfrom(parameters)
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            if error != nil {
                
                self.error = .unknownError
                NSNotificationCenter.defaultCenter().postNotificationName("loadFail", object: self)
                return
            } else {
                self.doc = TFHpple(HTMLData: data)
                
                self.terms = self.pullSection("term")
                self.subjects = self.pullSection("sel_subj")
                self.instructMethods = self.pullSection("sel_ism")
                self.instructors = self.pullSection("sel_instr")
                self.levels = self.pullSection("level")
                //TODO: Parse data
                
                NSNotificationCenter.defaultCenter().postNotificationName("loadSuccess", object: self)
                
            }
        }.resume()
    }
    
    private func pullSection(sectionID: String) -> [[String:String]] {
        var section: [[String:String]] = []
        let sectionNode = self.doc.searchWithXPathQuery("//select[@name='\(sectionID)']").first as! TFHppleElement
        
        var temp: [String: String]
        for item in sectionNode.childrenWithTagName("option") as! [TFHppleElement] {
            
            temp = item.attributes as! [String:String]
            temp["title"] = item.text().stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
            
            section.append(temp)
            
        }
        
        return section
    }
    
}

