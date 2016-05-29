//
//  SearchResultsStruct.swift
//  SBCC Coursewatch
//
//  Created by Justin Oroz on 5/29/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

struct SearchResults {
    init?(HTMLData: NSData){
        doc = TFHpple(HTMLData: HTMLData)
        let nodes = pullTextNodes()
        extractData(nodes)
        
    }
    
    private var doc: TFHpple
    private var data:  NSMutableArray = []
    
    func getCourses(section: Int) -> [[String:AnyObject]] {
        
        let subject = data[section] as! NSMutableDictionary
        
        return subject["courses"] as! [[String:AnyObject]]
    }
    
    func getClasses(section: Int, course: Int) -> [[String:String]] {
        let courses = getCourses(section)
        
        return courses[course]["classes"] as! [[String: String]]
    }
    
    func getSubjects() -> [[String:AnyObject]] {
        return data as! [[String: AnyObject]]
    }
    
    
    private func pullTextNodes() -> [TFHppleElement?] {
        //
        var textNodes: [TFHppleElement?] = []
        
        let subjectHeaderNodes = self.doc.searchWithXPathQuery("//tr/td[@class='default1'] | //tr/td[@class='default2'] | //td[@class='subject_header'] | //td[@class='crn_header']") as! [TFHppleElement]
        
        for headerNode in subjectHeaderNodes {
            
            textNodes.append(headerNode.firstTextNodeFromChild())
        }
        
        return textNodes
    }
    
    private mutating func extractData(nodes:[TFHppleElement?]) {
        var count = column.status
        let columnTitle = ["status","instructMethod","CRN","prereq/coreq","credit","type","mon","tues","wed","thur","fri","sat","sun","time","location","capacity","taken","remaining","wlCap","wlTaken","wlRemaining","instructor","date","weeks"]
        
        for node in nodes {
            
            if node?.attributes["class"] as! String? == "subject_header" {
                // Subject Header
                
                let courses: NSMutableArray = []
                let subject: NSMutableDictionary = ["title": node!.text().trimWhiteSpace(), "courses": courses]
                data.addObject(subject)
                
                
            } else if node?.attributes["class"] as! String? == "crn_header" {
                // CRN Header
                
                
                let subject = data[data.count-1] as! NSMutableDictionary
                let courses = subject["courses"] as! NSMutableArray
                let classes: NSMutableArray = []
                
                let thisCourse: NSMutableDictionary = ["title": node!.text().trimWhiteSpace(), "classes": classes]
                courses.addObject(thisCourse)
                
                count = .status
            } else {
                // detects when to start a new class instance
                if count == .outOfBounds{
                    count = .status
                }
                
                let subject = data[data.count-1] as! NSMutableDictionary
                let courses = subject["courses"] as! NSMutableArray
                let classes = courses[courses.count-1]["classes"] as! NSMutableArray
                
                if count == .status {
                    classes.addObject(NSMutableDictionary())
                }
                
                let thisClass = classes[classes.count-1] as! NSMutableDictionary
                
                if count == .tues && (thisClass["mon"] as? String != "M" && thisClass["mon"] != nil) {
                    // checks if the time is not a normal format
                    count = .location
                } else if count == .status && node?.text() == nil {
                    // checks for labs, dont have columns 0-4
                    // places nil in credit from the empty column 0
                    // next value contains .type
                    count = .credit
                } else if count == .taken && thisClass["status"] == nil {
                    // labs dont have colums 16-21
                    count = .date
                }
                
                thisClass[columnTitle[count.rawValue]] = node?.text().trimWhiteSpace()
                
                
                count = column(rawValue: count.rawValue + 1)!
                
            }
            
        }
        
    }
    
}

enum column: Int {
    case status, instructMethod, crn, pre_coreq, credit, type, mon, tues, wed, thur, fri, sat, sun, time
    case location, capacity, taken, remaining, wlCap, wlTaken, wlRemaining, instructor, date, weeks, outOfBounds
}


extension String {
    func trimWhiteSpace() -> String{
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
}


extension TFHppleElement {
    func containsText() -> Bool {
        if self.text() != nil {
            return true
        } else {
            return false
        }
    }
    
    func isEmpty() -> Bool {
        if self.text() == nil {
            return true
        } else {
            if self.text().stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty {
                return true
            } else {
                return false
            }
        }
    }
    
    func firstTextNodeFromChild() -> TFHppleElement? {
        if !self.isEmpty() {
            return self
        } else {
            var node: TFHppleElement = self
            
            while node.isEmpty()  && node.firstChild != nil {
                
                for child in node.children {
                    if child.containsText() {
                        node = child as! TFHppleElement
                        break
                    }
                }
                
                if node.isEmpty() && node.firstChild != nil {
                    node = node.firstChild
                }
            }
            
            if !node.containsText() {
                return nil
            } else {
                return node
            }
            
        }
    }
}