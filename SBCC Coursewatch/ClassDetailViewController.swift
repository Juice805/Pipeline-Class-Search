//
//  ClassDetailViewController.swift
//  SBCC Coursewatch
//
//  Created by Justin Oroz on 5/29/16.
//  Copyright © 2016 Justin Oroz. All rights reserved.
//

import UIKit

class ClassDetailViewController: UIViewController {
    
    var classData = [String: String]()
    
    @IBOutlet weak var crn: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.crn.text = classData["CRN"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
