//
//  ViewController.swift
//  Pipeline Class Search
//
//  Created by Justin Oroz on 11/17/14.
//  Copyright (c) 2014 Justin Oroz. All rights reserved.
//

import UIKit

class courselisting: NSObject {
    var subjects: [String] = []
    var semesters: [String] = []
}


let url = NSURL(string: "http://www.sbcc.edu/mobile/schedule/")

// class begin

class ViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let url = NSURL(string: "http://www.sbcc.edu/mobile/schedule/");
    var html = String()
    var sbcc = courselisting();

    override func viewDidLoad() {
        super.viewDidLoad()
                println(self.html)
        
        getSource(url!);
        
        sbcc.subjects.append("Computer Science")
        sbcc.semesters.append("Summer 2014")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            return 100.0
        } else {
            return 200.0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        if (component == 0) {
            return sbcc.semesters[row]
        } else {
            return sbcc.subjects[row]
        }
    }
    
    /*func pickerView(pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        
        var test = NSAttributedString()
        return test
    }*/

    
    func parse(html: String) {
        sbcc.subjects.append("Test")
        sbcc.subjects.append(html.substringToIndex(advance(html.startIndex, 2)))
        println(self.html)
    }
    
    func alertView(alertView: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        println("reloading")
    }
    
    func getSource(url: NSURL){
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
            
            if (error != nil) {
                println("whoops, something went wrong")
                
                let alert : UIAlertView = UIAlertView(title: "Oops!", message: "Something went wrong",       delegate: nil, cancelButtonTitle: "Reload")
                
                alert.show()
                
            } else {
                //println(self.html)
                self.html = NSString(data: data, encoding: NSUTF8StringEncoding)!
                self.parse(self.html);
                
                
            }
        }
        
    }
}

