//
//  TransitionSegue.swift
//  i3
//
//  Created by Ian Atha on 9/9/15.
//  Copyright (c) 2018 Mamabear, Inc. All rights reserved.
//

import Cocoa

class SecondViewController: NSViewController, MamabearInventoryListener {
    func workStarted(steps: Int) {
        self.progressIndicator.minValue = 0
        self.progressIndicator.maxValue = Double(steps)
        self.progressIndicator.startAnimation(nil)
    }

    func stepStarted(text: String) {
        self.status.stringValue = text
    }

    func stepCompleted() {
        self.progressIndicator.increment(by: 1)
        self.status.stringValue = ""
    }

    func workCompleted() {
        self.status.stringValue = ""
        self.progressIndicator.stopAnimation(nil)
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("next"), sender: nil)
    }

    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var status: NSTextField!

    override func viewDidAppear() {
        self.progressIndicator.minValue = 0

        let configuration = self.representedObject as! I3Configuration
        let inventory = MamabearInventory(listener: self,
                                          backendURL: configuration.backendURL,
                                          extraInfo: [
                                            "name": configuration.collected_name
            ])

        DispatchQueue.global(qos: .default).async {
            inventory.start()
        }
    }
}
