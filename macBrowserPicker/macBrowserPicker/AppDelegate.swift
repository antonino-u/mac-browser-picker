//
//  AppDelegate.swift
//  macBrowserPicker
//
//  Created by Antonino Urbano on 2016-03-10.
//  Copyright © 2016 Antonino Urbano. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(aNotification: NSNotification) {
    }
    
    func applicationWillTerminate(aNotification: NSNotification) {
    }
    
    func applicationWillFinishLaunching(notification: NSNotification) {
        let appleEventManager = NSAppleEventManager.sharedAppleEventManager()
        appleEventManager.setEventHandler(self, andSelector: #selector(AppDelegate.handleGetURLEvent(_:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))
    }
    
    func handleGetURLEvent(event: NSAppleEventDescriptor?, replyEvent: NSAppleEventDescriptor?) {
        if let urlString = event?.paramDescriptorForKeyword(AEKeyword(keyDirectObject))?.stringValue {
            if let lastBundleId = NSUserDefaults.standardUserDefaults().stringForKey("last_bundle_id") {
                //post a message to the vc to countdown then open the url
                openAppWithBundleIdentifier(lastBundleId, urlString: urlString)
                NSApp.terminate(self)
            }
        }
    }
    
    func openAppWithBundleIdentifier(bundleIdentifier: String, urlString: String) -> String {
        let task = NSTask()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-b", bundleIdentifier, urlString]
        let pipe = NSPipe()
        task.standardOutput = pipe
        task.standardError = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
        return output
    }

}

