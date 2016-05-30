//
//  SearchViewController.swift
//  SBCC Coursewatch
//
//  Created by Justin Oroz on 5/21/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit
import Buckets

class SearchViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    
    // TODO: Replace picker with table for subjects
    
    let url = "https://banner.sbcc.edu/PROD/pw_pub_sched.p_search"
    
    let searchData: SBCCSearch
    
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    required init?(coder aDecoder: NSCoder) {
        self.searchData = SBCCSearch(html: url)
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.alertDataFailedToLoad), name: "loadFail", object: self.searchData)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SearchViewController.dataLoaded), name: "loadSuccess", object: self.searchData)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print("didLoad")
        loading()
    }
    
    func loading(done done:Bool = false) {
        if done {
            loadingIndicator.stopAnimating()
            blurView.hidden = true
            searchButton.enabled = true
            termProgPicker.userInteractionEnabled = true
            subjectTable.userInteractionEnabled = true
            print(done)
        } else {
            loadingIndicator.startAnimating()
            blurView.hidden = false
            searchButton.enabled = false
            termProgPicker.userInteractionEnabled = false
            subjectTable.userInteractionEnabled = false
            print(done)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func alertDataFailedToLoad(notification: NSNotification) {
        let alert = UIAlertController(title: "Error", message: "Check internet connection", preferredStyle: .Alert)
        let reload = UIAlertAction(title: "Try Again", style: .Default, handler: {
            (action) in
            
            self.searchData.reload(self.url)
        })
        
        alert.addAction(reload)
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func dataLoaded(notification: NSNotification){
        //TODO: Unhide all stuff & reload pickers
        
        dispatch_async(dispatch_get_main_queue(), {
            self.subjectTable.reloadSections(NSIndexSet.init(index: 0), withRowAnimation: .Fade)
            self.termProgPicker.reloadAllComponents()
            self.subjectTable.selectRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), animated: true, scrollPosition: UITableViewScrollPosition.None)
            
            self.loading(done: true)
            print("data loaded")
        })
    }
    
    
    @IBOutlet weak var termProgPicker: UIPickerView!
    @IBOutlet weak var subjectTable: UITableView!
    
    // MARK: - Picker View Delegate Functions
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        switch pickerView {
        case self.termProgPicker:
            return 2
        default:
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch pickerView {
        case self.termProgPicker:
            if component == 0 {
                return searchData.terms.count
            } else {
                return searchData.levels.count
            }
        default:
            return 0
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case self.termProgPicker:
            if component == 0 {
                return searchData.terms[row]["title"]
            } else {
                return searchData.levels[row]["title"]
            }
        default:
            return ""
        }
        
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.termProgPicker:
            NSURLSession.sharedSession().invalidateAndCancel()
            searchData.reload(self.url, parameters: searchPageParameters())
            loading()
        default:
            break
        }
    }
    
    func searchPageParameters() -> [String: String] {
        return ["term": searchData.terms[termProgPicker.selectedRowInComponent(0)]["value"]!,
                "level": searchData.levels[termProgPicker.selectedRowInComponent(1)]["value"]!]
    }
    
    // MARK: - TableView Delegate Functions
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.subjects.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("subject")
        cell!.textLabel?.text = searchData.subjects[indexPath.row]["title"]
        return cell!
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            for index in tableView.indexPathsForSelectedRows! {
                if index.row != 0 {
                    tableView.deselectRowAtIndexPath(index, animated: false)
                }
                
            }
            
        } else {
            tableView.deselectRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), animated: false)
        }
    }
    
    func tableView(tableView: UITableView, willDeselectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.row != 0 {
            if tableView.indexPathsForSelectedRows?.count == 1 {
                tableView.selectRowAtIndexPath(NSIndexPath.init(forRow: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
            }
            return indexPath
        } else {
            return nil
        }
        
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        NSURLSession.sharedSession().invalidateAndCancel()
        
        if segue.identifier == "displayResults" {
            let searchNavController = segue.destinationViewController as! UINavigationController
            let resultsView = searchNavController.topViewController as! ClassListViewController
            let request = resultsView.request
            
            // set up request
            request.HTTPMethod = "POST"
            
            var postDict : Multimap<String,String> = Multimap<String,String>()
            postDict.insertValue(searchData.terms[termProgPicker.selectedRowInComponent(0)]["value"]!, forKey: "TERM")
            postDict.insertValue(searchData.terms[termProgPicker.selectedRowInComponent(0)]["title"]!, forKey: "TERM_DESC")
            
            // MARK: REQUIRED TERMS
            postDict.insertValue("dummy", forKey: "sel_subj")
            postDict.insertValue("dummy", forKey: "sel_day")
            postDict.insertValue("dummy", forKey: "sel_schd")
            postDict.insertValue("dummy", forKey: "sel_camp")
            postDict.insertValue("dummy", forKey: "sel_ism")
            postDict.insertValue("dummy", forKey: "sel_sess")
            postDict.insertValue("dummy", forKey: "sel_instr")
            postDict.insertValue("dummy", forKey: "sel_ptrm")
            postDict.insertValue("%", forKey: "sel_ptrm")
            postDict.insertValue("CR", forKey: "level")
            postDict.insertValue(searchData.levels[termProgPicker.selectedRowInComponent(1)]["value"]!, forKey: "level")
            
            
            // MARK: REQUIRED (REPLACEABLE)
            postDict.insertValue("5", forKey: "begin_hh")
            postDict.insertValue("0", forKey: "begin_mi")
            postDict.insertValue("a", forKey: "begin_ap")
            postDict.insertValue("11", forKey: "end_hh")
            postDict.insertValue("0", forKey: "end_mi")
            postDict.insertValue("p", forKey: "end_ap")
            
            // MARK: OPTIONAL
            //        postDict.insertValue("N", forKey: "aa")
            //        postDict.insertValue("N", forKey: "bb")
            //        postDict.insertValue("N", forKey: "dd")
            //        postDict.insertValue("N", forKey: "ee")
            //        postDict.insertValue("N", forKey: "gg")
            
            // MARK: USER INPUT
            
            
            
            
            for index in self.subjectTable.indexPathsForSelectedRows! {
                postDict.insertValue(searchData.subjects[index.row]["value"]!, forKey: "sel_subj")
            }
            
            postDict.insertValue("%", forKey: "sel_ism")
            postDict.insertValue("%", forKey: "sel_instr")
            
            
            request.setHTTPBodyfrom(postDict)
            request.mainDocumentURL = NSURL(string: url)
            
            
        }
        
    }
    
    
    
 
}

extension NSMutableURLRequest {
    
    func setHTTPBodyfrom(multimap:  Multimap<String, String>) {
        var body: String = ""
        
        for item in multimap {
            if body == "" {
                body += item.0 + "=" + item.1
            } else {
                body += "&" + item.0 + "=" + item.1
            }
        }
        
        body = body.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        self.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    func setHTTPBodyfrom(dictionary:  [String: String]) {
        var body: String = ""
        
        for item in dictionary {
            if body == "" {
                body += item.0 + "=" + item.1
            } else {
                body += "&" + item.0 + "=" + item.1
            }
        }
        
        body = body.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!
        self.HTTPBody = body.dataUsingEncoding(NSUTF8StringEncoding)
    }
    
    
    
}

