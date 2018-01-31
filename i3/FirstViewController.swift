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
    @IBOutlet weak var nameTextField: NSTextField!

    @IBOutlet weak var logo: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let fileUrl = Bundle.main.url(forResource: "Fleet", withExtension: "plist"),
            let data = try? Data(contentsOf: fileUrl) {
            if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String] {
                if let logoDataEncoded = result?["Logo"] {
                    if let imageData = NSData(base64Encoded: logoDataEncoded) {
                        logo.image = NSImage(data: imageData as Data)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let next = segue.destinationController as! SecondViewController
        next.representedObject = nameTextField.stringValue
    }

    override var representedObject: Any? {
        didSet {
        }
    }    
}

