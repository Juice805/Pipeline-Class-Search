//
//  ClassListController.swift
//  Pipeline Class Search
//
//  Created by Justin Oroz on 11/17/14.
//  Copyright (c) 2014 Justin Oroz. All rights reserved.
//

import UIKit

class classCell: UITableViewCell {
    //
    @IBOutlet weak var moreInfo: UIButton!
    @IBOutlet weak var CRN: UILabel!
}

class ClassListController: UITableViewController {
    
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!

    var url = String()
    var html = String()
    var subject = String()
    
    
    var listing = Dictionary<String, Dictionary<String, String> >()
    var courses = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        grabHTML(self.url)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func grabHTML(site: String) {
        self.loadingIndicator.hidden=false;
        var info = String();

        getHTML(site, info: info) {
            
            responseString, error in
            
            if responseString == nil {
                println("Error during post: \(error)")
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
                return
            } else {
                self.loadingIndicator.hidden=true
                // use responseString here
                self.html=responseString
                self.parse()
                self.tableView.reloadData()
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
    
    func parse(){
        
        var start = self.html.rangeOfString("<ul data-role=\"listview\">")?.endIndex
        self.html = self.html.substringFromIndex(start!)
        var end = self.html.rangeOfString("</ul>")?.startIndex
        self.html = self.html.substringToIndex(end!)
        
        if (self.html.rangeOfString("No courses meet the criteria. Please search again.") != nil) {
            var alertController = UIAlertController(title: "No Courses Found", message: "Edit filter", preferredStyle: .Alert)
            
            // Create the actions
            var reloadAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("OK Pressed")
                // somehow go back to previous page
                return
            }
            
            // Add the actions
            alertController.addAction(reloadAction)
            
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
        } else {
            //continue parsing
            println(html)
            
            var remainingHTML, divider, course, CRN, status, fullCourse, subject, crseNumber: String
            
            remainingHTML = self.html
            
            while (remainingHTML.rangeOfString("<li data-role=\"list-divider\">") != nil) { //while more dividers
                start = remainingHTML.rangeOfString("<li data-role=\"list-divider\">")?.endIndex
                remainingHTML = remainingHTML.substringFromIndex(start!)
                end = remainingHTML.rangeOfString("<!--<span class=\"ui-li-count\">count</span>--></li>")?.startIndex
                fullCourse = remainingHTML.substringToIndex(end!)
                
                end = remainingHTML.rangeOfString("</span>--></li>")?.endIndex
                remainingHTML = remainingHTML.substringFromIndex(end!)
                
                //strip course number and name from info
                end = fullCourse.rangeOfString(" - ")?.startIndex
                subject = fullCourse.substringToIndex(end!)
                start = fullCourse.rangeOfString(" - ")?.endIndex
                fullCourse = fullCourse.substringFromIndex(start!)
            
                
                course = String()
                while (fullCourse.rangeOfString(" ")? != nil) { //stops before the final word, which is the course number
                    end = fullCourse.rangeOfString(" ")?.startIndex
                    course += fullCourse.substringToIndex(end!)
                    start = fullCourse.rangeOfString(" ")?.endIndex
                    fullCourse = fullCourse.substringFromIndex(start!)
                    if (fullCourse.rangeOfString(" ")? != nil) { //adds space if not last word
                        course += " "
                    }
                    
                }
                
                crseNumber = fullCourse
                
                println(self.subject + " " + crseNumber + " - " + course)
                
                while ((remainingHTML.rangeOfString("<li data-role=\"list-divider\">")?.startIndex > remainingHTML.rangeOfString("<a href=")?.startIndex) || ((remainingHTML.rangeOfString("<li data-role=\"list-divider\">")?.startIndex == nil && remainingHTML.rangeOfString("<a href=")?.startIndex != nil))) { //while course comes before divider OR remaining courses, with no dividers left (e.g. last divider)
                    
                    end = remainingHTML.rangeOfString("<a href=\"")?.endIndex //cuts out quotes
                    remainingHTML = remainingHTML.substringFromIndex(end!)
                    
                    CRN = pullText(remainingHTML, preceding: "&crn=", following: "\"")
                    
                    status = pullText(remainingHTML, preceding: " - ", following: "</a>")
                    
                    trim(&remainingHTML, after: "</li>")
                    
                    if (courses.count == 0) {
                        courses.append(crseNumber)
                    }else if (courses[courses.count-1] != crseNumber){
                        courses.append(crseNumber)
                        courses.sort(<)
                    }
                    
                    
                    
                    if (listing[crseNumber] == nil) {
                        listing[crseNumber] = Dictionary<String, String>()
                    }
                    
                    listing[crseNumber]!["title"] = course
                    

                    listing[crseNumber]![CRN] = status
                    
                    
                    println(CRN + " - " + status)
                    //listing[fullCourse]![0] = [CRN, status]
                    //println(listing[fullCourse]![0][0] + " - " + listing[fullCourse]![0][1]) //niiiiiiiice worked
                    //listing[fullCourse]?.count
                }
            }
        }
                

    }

    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        
        
    }
    
    func pullText (var source: String, preceding: String, following: String) -> String{
        var start = source.rangeOfString(preceding)?.endIndex
        source = source.substringFromIndex(start!)
        var end = source.rangeOfString(following)?.startIndex
        var output = source.substringToIndex(end!)
        return output
    }
    
    func trim(inout source: String, after: String) {
        var start = source.rangeOfString(after)?.endIndex
        source = source.substringFromIndex(start!)
    }
    
    //TABLE VIEW
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int { // Default is 1 if not implemented
        return listing.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var courseNum = courses[section]
        var derp = listing[courseNum]!
        return derp.count - 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = classCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        var courseNum = courses[indexPath.section]
        var crn = listing[courseNum]?.keys.array[indexPath.row+1]
        cell.textLabel.text = crn! + " - " + listing[courseNum]![crn!]!
        
        cell.moreInfo = UIButton();
                
        return cell;
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var courseNum = courses[section]
        
        return (self.subject + " \(courseNum) - " + listing[courseNum]!["title"]!)
    }
}
