//
//  CachedExecutor.swift
//  i3
//
//  Created by Ian Atha on 2/6/18.
//  Copyright © 2018 Ian Atha. All rights reserved.
//

import Foundation

class CachedExecutor {
    private var cache = Dictionary<String, [String]>()

    init() {

    }

    func exec(cmd: String, args: [String]) -> [String] {
        let cache_key = cmd + "~" + args.joined(separator: "~")

        if cache[cache_key] == nil {
            let task = Process()
            task.launchPath = cmd
            task.arguments = args

            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let dataAsString: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            cache[cache_key] = dataAsString.components(separatedBy: "\n")
        }

        return cache[cache_key]!
    }
}
