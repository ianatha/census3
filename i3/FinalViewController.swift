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
    var webContinuation: String = ""

    override func viewDidAppear() {
        self.webContinuation = self.representedObject as! String
    }

    @IBAction func okButtonClicked(sender: AnyObject) {
        if let url = URL(string: self.webContinuation), NSWorkspace.shared.open(url) {
            exit(0)
        }
    }
}
