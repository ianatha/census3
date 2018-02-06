//
//  File.swift
//  i3
//
//  Created by Ian Atha on 2/6/18.
//  Copyright © 2018 Ian Atha. All rights reserved.
//

import Foundation
import Cocoa

class I3Configuration {
    var fleetImage: NSImage?
    var fleetFriendlyName: String?

    var backendURL: String = "https://requestb.in/1hx6d7u1"

    var collected_name: String = ""

    init(fleetImage: NSImage, fleetFriendlyName: String) {
        self.fleetImage = fleetImage
        self.fleetFriendlyName = fleetFriendlyName
    }

    init(fromPlist: URL) {
        if let data = try? Data(contentsOf: fromPlist) {
            if let result = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: String] {
                if let logoDataEncoded = result?["Logo"] {
                    if let imageData = NSData(base64Encoded: logoDataEncoded) {
                        self.fleetImage = NSImage(data: imageData as Data)
                    }
                }

                if let fleetFriendlyName = result?["FleetFriendlyName"] {
                    self.fleetFriendlyName = fleetFriendlyName
                }
            }
        }
    }
}
