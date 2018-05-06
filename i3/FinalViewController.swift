//
//  TransitionSegue.swift
//  i3
//
//  Created by Ian Atha on 9/9/15.
//  Copyright (c) 2018 Mamabear, Inc. All rights reserved.
//

import Cocoa
import Darwin

class FinalViewController: NSViewController {
    var webContinuationSuccess: Bool = false
    var webContinuationResult: [String:Any] = [:]

    @IBOutlet weak var image: NSImageView!
    
    override func viewWillAppear() {
        let input = self.representedObject as! (Bool, [String:Any])
        webContinuationSuccess = input.0
        webContinuationResult = input.1
        
        if (webContinuationSuccess) {
            if webContinuationResult["url"] != nil {
                image.image = NSImage(named: NSImage.Name("one_more_step"))
                response.stringValue = "One last step... We'll open up your browser."
            } else if webContinuationResult["msg"] != nil {
                image.image = NSImage(named: NSImage.Name("success"))
                response.stringValue = webContinuationResult["msg"] as! String
            } else if webContinuationResult["err"] != nil {
                image.image = NSImage(named: NSImage.Name("failure"))
                response.stringValue = webContinuationResult["err"] as! String
            } else {
                image.image = NSImage(named: NSImage.Name("success"))
                response.stringValue = "Thank you for your help!"
            }
        } else {
            image.image = NSImage(named: NSImage.Name("failure"))
            response.stringValue = webContinuationResult["err"] as! String
        }
    }
    
    @IBOutlet weak var response: NSTextField!
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        if let _url = self.webContinuationResult["url"] as? String, let url = URL(string: _url) {
            NSWorkspace.shared.open(url)
        }
        exit(0)
    }
}
