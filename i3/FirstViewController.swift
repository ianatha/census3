//
//  TransitionSegue.swift
//  i3
//
//  Created by Ian Atha on 9/9/15.
//  Copyright (c) 2018 Mamabear, Inc. All rights reserved.
//

import Darwin
import Cocoa

class FirstViewController : NSViewController {
    let configuration = I3Configuration(fromPlist: Bundle.main.url(forResource: "Fleet", withExtension: "plist")!)

    @IBOutlet weak var nameTextField: NSTextField!

    @IBOutlet weak var companyName: NSTextFieldCell!
    @IBOutlet weak var companyLogo: NSImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        companyLogo.image = configuration.fleetImage!
        companyName.stringValue = configuration.fleetFriendlyName!
    }

    override func viewDidAppear() {
        NSApp.activate(ignoringOtherApps: true)
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        configuration.collected_name = nameTextField.stringValue

        let next = segue.destinationController as! SecondViewController
        next.representedObject = configuration
    }

    override var representedObject: Any? {
        didSet {
        }
    }    
}
