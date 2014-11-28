//
//  ViewController.swift
//  Pipeline Class Search
//
//  Created by Justin Oroz on 11/17/14.
//  Copyright (c) 2014 Justin Oroz. All rights reserved.
//

import UIKit

class courselisting {
    var subjects: [String] = []
    var semesters: [String] = []
    var semesterNum: [String] = []
    var semesterNumDict = Dictionary<String, String>()
}

// class begin

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var picker: UIPickerView!
    var sbcc = courselisting();
    var html = "No Info Received"
    var searchEnabled = false;
    
    @IBOutlet weak var openClassesOnly: UISwitch!
    @IBOutlet weak var onlineClassesOnly: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        grabHTML("http://www.sbcc.edu/mobile/schedule/")
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func grabHTML(site: String){
        var info = String();
        
        sbcc.semesters.append("Loading")
        sbcc.subjects.append("Please Wait")

        
        getHTML(site, info: info) {
            responseString, error in
            
            if responseString == nil {
                println("Error during post: \(error)") // ADD ALERT HERE
                
                // Create the alert controller
                var alertController = UIAlertController(title: "Whoops!", message: "Check internet connection", preferredStyle: .Alert)
                
                // Create the actions
                var reloadAction = UIAlertAction(title: "Reload", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    println("Reload Pressed")
                    self.grabHTML(site)
                    return
                }
                
                // Add the actions
                alertController.addAction(reloadAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                // use responseString here
                self.html=responseString
                self.sbcc.subjects.removeAll()
                self.sbcc.semesters.removeAll()
                self.parse()
                self.picker.reloadAllComponents()
                self.searchEnabled=true;
            }
        }

    }

    
    func getHTML(url: String, info: String, completionHandler: (responseString: NSString!, error: NSError!) -> ()) {
        var URL: NSURL = NSURL(string: url)!
        var request:NSMutableURLRequest = NSMutableURLRequest(URL:URL)
        request.HTTPMethod = "POST";
        var bodyData = info;
        request.HTTPBody = bodyData.dataUsingEncoding(NSUTF8StringEncoding);
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()){
            
            response, data, error in
            
            var output: NSString!
            
            if data != nil {
                output = NSString(data: data, encoding: NSUTF8StringEncoding)
            }
            
            completionHandler(responseString: output, error: error)
        }
    }
    
    func parse() {
        
        //grab semesters
        var start = html.rangeOfString("<select NAME=\"term\"  id=\"term\"")?.startIndex
        var end = html.rangeOfString("</select>")?.endIndex
        var termHTML = html.substringToIndex(end!)
        termHTML = termHTML.substringFromIndex(start!)
        
        var remainingHTML = html.substringFromIndex(end!)

        
        start = remainingHTML.rangeOfString("<SELECT NAME=\"subj\"  id=\"subj\"")?.startIndex
        end = remainingHTML.rangeOfString("</SELECT>")?.endIndex
        var subjHTML = remainingHTML.substringToIndex(end!)
        subjHTML = subjHTML.substringFromIndex(start!)
        
        var term, termNum: String;
        while (termHTML.rangeOfString("<option value=\"") != nil) {
            end = termHTML.rangeOfString(",")?.startIndex
            termNum = termHTML.substringToIndex(end!)
            start = termNum.rangeOfString("<option value=\"")?.endIndex
            termNum = termNum.substringFromIndex(start!)
            
            termHTML = termHTML.substringFromIndex(end!) //cuts off earlier html
            
            end = termHTML.rangeOfString("\"")?.startIndex
            term = termHTML.substringToIndex(end!)
            start = termHTML.rangeOfString(",")?.endIndex
            term = term.substringFromIndex(start!)
            
            termHTML = termHTML.substringFromIndex(end!) //cuts off earlier html

            self.sbcc.semesterNum.append(termNum)
            self.sbcc.semesterNumDict[term]=termNum
            self.sbcc.semesters.append(term)


        }
        
        var subj, subjNum: String
        start = subjHTML.rangeOfString("<option value=\"A")?.startIndex  // starts after the placeholder
        subjHTML = subjHTML.substringFromIndex(start!)
        
        while (subjHTML.rangeOfString("<option value=\"") != nil) {
            end = subjHTML.rangeOfString("\" >")?.startIndex
            subjNum = subjHTML.substringToIndex(end!)
            start = subjNum.rangeOfString("<option value=\"")?.endIndex
            subjNum = subjNum.substringFromIndex(start!)
           
            end = subjHTML.rangeOfString("\" >")?.endIndex
            subjHTML = subjHTML.substringFromIndex(end!) //cuts off earlier html

            self.sbcc.subjects.append(subjNum)
        }
        
        //html.substringToIndex()
    }
    
    
    // PICKER VIEW FUNCTIONS
    // returns the number of 'columns' to display.
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 2;
    }
    
    // returns the # of rows in each component..
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (component == 0){
            return sbcc.semesters.count;
        } else {
            return sbcc.subjects.count;
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        if (component == 0) {
            return 200.0
        } else {
            return 100.0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (component == 0) {
            return sbcc.semesters[row]
        } else {
            return sbcc.subjects[row]
        }
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        var info = String();
        println("ALert Pressed")

        getHTML("http://www.sbcc.edu/mobile/schedule/", info: info) {
            responseString, error in
            
            if responseString == nil {
                println("Error during post: \(error)") // ADD ALERT HERE
                return
            }
            // use responseString here
            self.html=responseString
            self.sbcc.subjects.removeAll()
            self.sbcc.semesters.removeAll()
            self.parse()
            self.picker.reloadAllComponents()
            
        }
    }
    
    // SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "search"{
            let listView = segue.destinationViewController as ClassListController
            var searchTerm = pickerView(picker, titleForRow: picker.selectedRowInComponent(0), forComponent: 0)
            var searchSubj = pickerView(picker, titleForRow: picker.selectedRowInComponent(1), forComponent: 1)
            var online: Character
            if (onlineClassesOnly.on) {
                online = "Y"
            } else {online = "N"}
            
            var open: Character
            if (openClassesOnly.on) {
                open = "Y"
            } else {open = "N"}
            
            listView.url = "http://www.sbcc.edu/mobile/schedule/schedule.php?term=\(self.sbcc.semesterNumDict[searchTerm]!)%2C\(searchTerm)&subj=\(searchSubj)&status=\(open)&im=\(online)"
            listView.subject = searchSubj
            
            listView.url.replaceRange(listView.url.rangeOfString(" ")!, with: "%20")
            println(listView.url)
            
        }
    }
}