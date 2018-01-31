//
//  TransitionSegue.swift
//  i3
//
//  Created by Ian Atha on 9/9/15.
//  Copyright (c) 2018 Mamabear, Inc. All rights reserved.
//

import Cocoa

class SecondViewController: NSViewController {
    let backend_url = "https://requestb.in/1hx6d7u1"
    let UI_STRING_transmitting_to_mothership = "Transmitting to mothership..."
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var status: NSTextField!
    
    var exec_cache = Dictionary<String, [String]>()
    
    func cached_exec(cmd: String, args: [String]) -> [String] {
        let cache_key = cmd + "~" + args.joined(separator: "~")
        
        if exec_cache[cache_key] == nil {
            let task = Process()
            task.launchPath = cmd
            task.arguments = args
            
            let pipe = Pipe()
            task.standardOutput = pipe
            task.launch()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let dataAsString: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
            exec_cache[cache_key] =  dataAsString.components(separatedBy: "\n")
        }
        
        return exec_cache[cache_key]!
    }
    
    func system_profile(category: String, name: String) -> String {
        let profile = cached_exec(cmd: "/usr/sbin/system_profiler", args: [category]).map({ $0.components(separatedBy: ": ") })

        let result = profile.filter({ $0[0].range(of: name) != nil }).map({ $0[1] })
        
        return result[0]
    }
    
    func users() -> [String] {
        return cached_exec(cmd: "/bin/ls", args: ["/Users"]).filter({ $0 != "Guest" && $0 != "Shared" })
    }
    
    func software_version() -> String {
        let sw_vers = cached_exec(cmd: "/usr/bin/sw_vers", args: [])
        let sw_vers_parsed = sw_vers.map { (x: String) -> String in
            let parts: [String] = x.components(separatedBy: ":")
            if parts.count == 2 {
                return parts[1].trimmingCharacters(in: NSCharacterSet.whitespaces)
            } else {
                return ""
            }
        }
        
        return sw_vers_parsed.joined(separator: " ")
    }
    
    func your_first_name() -> String {
        return self.representedObject as! String;
    }
    
    func transmitInventory(url: String, parameters: [String: AnyObject], completion: @escaping () -> ()) {
        let parameterString = parameters.stringFromHttpParameters()
        let requestURL = NSURL(string:"\(url)?\(parameterString)")!
        
        let task = URLSession.shared.dataTask(with: requestURL as URL) {(data, response, error) in
            completion()
        }
        
        task.resume()
    }
    
    func resolveModelName() -> String {
        let sn = system_profile(category: "SPHardwareDataType", name: "Serial Number (system)")
        let lastfour: String = String(sn.suffix(4))
        let requestURL = NSURL(string:"http://support-sp.apple.com/sp/product?cc=\(lastfour)")!
        
        let semaphore = DispatchSemaphore(value: 0)
        var result = ""

        let task = URLSession.shared.dataTask(with: requestURL as URL) {(data, response, error) in
            if ((response as! HTTPURLResponse).statusCode == 200) {
                let xml = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!
                let startRange = xml.range(of: "<configCode>")
                let endRange = xml.range(of: "</configCode>")
                
                result = xml.substring(with: NSRange(location: startRange.location + startRange.length, length: endRange.location - (startRange.location + startRange.length)))
            } else {
                result = "error"
            }

            semaphore.signal()
        }
        
        task.resume()
        semaphore.wait(timeout: .distantFuture)

        return result
    }

    func start() {
        let inventory_data_spec: Dictionary<String, () -> String> = [
            "name": { self.your_first_name() },
            "software_version": { self.software_version() },
            "model_id": { self.system_profile(category: "SPHardwareDataType", name: "Model Identifier") },
            "serial_number": { self.system_profile(category: "SPHardwareDataType", name: "Serial Number (system)") },
            "model_desc": { self.resolveModelName() },
            "processor_name": { self.system_profile(category: "SPHardwareDataType", name: "Processor Name") },
            "processor_speed": { self.system_profile(category: "SPHardwareDataType", name: "Processor Speed") },
            "processor_cores": { self.system_profile(category: "SPHardwareDataType", name: "Total Number of Cores") },
            "memory": { self.system_profile(category: "SPHardwareDataType", name: "Memory") },
            "hardware_uuid": { self.system_profile(category: "SPHardwareDataType", name: "Hardware UUID") },
            "boot_rom_version": { self.system_profile(category: "SPHardwareDataType", name: "Boot ROM Version") },
            "smc_version": { self.system_profile(category: "SPHardwareDataType", name: "SMC Version (system)") },
            "local_time": {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ";
                return formatter.string(from: Date())
            },
            "users": { self.users().joined(separator: ";") },
            "storage_capacity": { self.system_profile(category: "SPStorageDataType", name: "Capacity") },
            "inventory_software": { "io.mamabear.i3#macos" },
        ]

        var inventory = Dictionary<String, String>()
        DispatchQueue.main.async {
            self.progressIndicator.minValue = 0
            self.progressIndicator.maxValue = Double(inventory_data_spec.count)
            self.progressIndicator.startAnimation(nil)
        }

        for (name, closure) in inventory_data_spec {
            DispatchQueue.main.async {
                self.progressIndicator.increment(by: 1)
                self.status.stringValue = name
            }
            inventory[name] = closure()
        }

        DispatchQueue.main.async {
            self.status.stringValue = self.UI_STRING_transmitting_to_mothership
        }
        
        self.transmitInventory(url: backend_url, parameters: inventory as [String : AnyObject], completion: {
                DispatchQueue.main.async {
                    self.progressIndicator.stopAnimation(nil)
                    self.status.stringValue = ""
                    self.performSegue(withIdentifier: NSStoryboardSegue.Identifier("next"), sender: nil)
                }
        })
    }
    
    override func viewDidAppear() {
        DispatchQueue.global(qos: .default).async {
            self.start()
        }
    }
}
