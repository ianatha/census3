//
//  TransitionSegue.swift
//  i3
//
//  Created by Ian Atha on 9/9/15.
//  Copyright (c) 2018 Mamabear, Inc. All rights reserved.
//

import Cocoa

class SecondViewController: NSViewController, MamabearInventoryListener {
    var webContinuationSuccess: Bool = false
    var webContinuationResult: [String : Any] = [:]

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

    func workCompleted(webContinuationSuccess: Bool, webContinuationResult: [String: Any]) {
        self.status.stringValue = ""
        self.progressIndicator.stopAnimation(nil)

        self.webContinuationSuccess = webContinuationSuccess 
        self.webContinuationResult = webContinuationResult
        self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("next"), sender: self)
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        let next = segue.destinationController as! FinalViewController
        next.representedObject = (self.webContinuationSuccess, self.webContinuationResult)
    }

    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var status: NSTextField!

    override func viewDidAppear() {
        self.progressIndicator.minValue = 0

        let configuration = self.representedObject as! I3Configuration
        let inventory = MamabearInventory(listener: self,
                                          backendURL: configuration.backendURL,
                                          extraInfo: [:])

        DispatchQueue.global(qos: .default).async {
            inventory.start()
        }
    }
}
