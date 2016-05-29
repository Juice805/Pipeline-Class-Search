//
//  ClassListViewController.swift
//  SBCC Coursewatch
//
//  Created by Justin Oroz on 5/20/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class ClassListViewController: UITableViewController, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var loadingIndic: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    
    let request: NSMutableURLRequest = NSMutableURLRequest(URL: NSURL(string: "https://banner.sbcc.edu/PROD/pw_pub_sched.p_listthislist")!)
    private var results: SearchResults? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // TODO: Add loading screen
        
        
        loadingIndic.startAnimating()
        loadingIndic.hidesWhenStopped = true
        loadingIndic.color = UIColor.blackColor()
        self.view.addSubview(loadingIndic)
        loadingIndic.frame = CGRect(origin: self.tableView.bounds.origin, size: self.tableView.bounds.size)
        searchBar.hidden = true
        tableView.scrollEnabled = false
        
        retrieveSearchResults(self.request)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
    func retrieveSearchResults(request: NSMutableURLRequest) {
        
        NSURLSession.sharedSession().dataTaskWithRequest(request) {
            (data, response, error) in
            
            guard error == nil && data != nil else {                                                          // check for fundamental networking error
                print("error=\(error)")
                // TODO: Alert
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
                // TODO: Alert
            }
            
            _ = NSString(data: data!, encoding: NSUTF8StringEncoding)!
            //print("responseString = \(responseString)")
            
            
            self.results = SearchResults(HTMLData: data!)
            // parse data
            
            
            
            // TODO: Clear loading screen, refresh table
            self.tableView.reloadData()
            self.loadingIndic.stopAnimating()
            self.loadingIndic.hidden = true
            self.view.willRemoveSubview(self.loadingIndic)
            self.searchBar.hidden = false
            self.tableView.scrollEnabled = true
            
            }.resume()
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (results == nil) {
            return 1
        } else {
            return results!.getSubjects().count
        }
        
    }
     
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (results == nil) {
            return 1
        } else {
            
            let courses = results!.getCourses(section)
            var count = courses.count
            
            for i in 0..<courses.count {
                count += results!.getClasses(section, course: i).count
            }
            
            return count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if results == nil { // in case results havent loaded yet
            return UITableViewCell()
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("section")!
            
            let courseInfo = (results!.getCourses(indexPath.section)[0]["title"] as? String)?.componentsSeparatedByString(" - ")
            cell.textLabel?.text = courseInfo![0]
            cell.detailTextLabel?.text = courseInfo![1]
            return cell
        }
        
        var count = 0
        var course = 0
        
        while count < indexPath.row {
            count += results!.getClasses(indexPath.section, course: course).count + 1
            course += 1
        }
        
        if count == indexPath.row {
            let cell = tableView.dequeueReusableCellWithIdentifier("section")!
            let courseInfo = (results!.getCourses(indexPath.section)[course]["title"] as? String)?.componentsSeparatedByString(" - ")
            cell.textLabel?.text = courseInfo?[0]
            cell.detailTextLabel?.text = courseInfo?[1]
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("class")! as! ClassTableViewCell
            course -= 1
            let thisClass = indexPath.row - (count - results!.getClasses(indexPath.section, course: course).count)
            let classData = results!.getClasses(indexPath.section, course: course)[thisClass]
            cell.classData = classData
            
            // TODO: Put data in cells
            cell.status!.text = classData["status"]
            cell.title!.text = classData["CRN"]
            cell.instructor!.text = classData["instructor"]
            
            cell.format()
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (results == nil) {
            return nil
        } else {
            return results!.getSubjects()[section]["title"] as? String
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20.0
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if results != nil {
            let courseHeight = CGFloat(40.0)
            let classHeight = CGFloat(100.0)
            
            if indexPath.row == 0 {
                return courseHeight
            }
            
            var count = 0
            var course = 0
            
            while count < indexPath.row {
                count += results!.getClasses(indexPath.section, course: course).count + 1
                course += 1
            }
            
            if count == indexPath.row {
                return courseHeight
            } else {
                return classHeight
            }
        } else {
            return 0
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //
        switch segue.identifier {
        case "classdetail"?:
            let cell = self.tableView.cellForRowAtIndexPath(self.tableView.indexPathForSelectedRow!) as! ClassTableViewCell
            let dest = segue.destinationViewController as! ClassDetailViewController
            dest.classData = cell.classData
            break
        default:
            break
        }
    }
    
}



