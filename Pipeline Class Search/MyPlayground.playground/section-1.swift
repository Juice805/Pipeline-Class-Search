// Playground - noun: a place where people can play

import UIKit
import Foundation
import XCPlayground
XCPSetExecutionShouldContinueIndefinitely()

class courselisting: NSObject {
    var subjects: [String] = []
    var semesters: [String] = []
}


let url = NSURL(string: "http://www.sbcc.edu/mobile/schedule/");
var html = String()
var sbcc = courselisting();
let request = NSURLRequest(URL: url!)

NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
    
    html = NSString(data: data, encoding: NSUTF8StringEncoding)!
    
    if (error != nil) {
        println("whoops, something went wrong")
    } else {
        println(html)
    }
    
    var test = html.rangeOfString("html")?.startIndex

}

println(html)
