//
//  ViewController.swift
//  macBrowserPicker
//
//  Created by Antonino Urbano on 2016-03-10.
//  Copyright © 2016 Antonino Urbano. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    let scheme = "http"
    let currentBundleId = NSBundle.mainBundle().bundleIdentifier
    
    let imageColumnIdentifier = "imageColumn"
    let nameColumnIdentifier = "nameColumn"
    let bundleIdColumnIdentifier = "bundleIdColumn"
    
    var appsInfo = [ApplicationInfo]()
    var countdownSecondsRemaining = 3
    var countdownTimer: NSTimer?
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var countdownContainer: NSView!
    @IBOutlet weak var countdownLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override var representedObject: AnyObject? {
        didSet {
        }
    }
    
    private func setupView() {
        
        //setup the actual view
        countdownContainer.wantsLayer = true
        countdownContainer.layer?.backgroundColor = NSColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        countdownContainer.layer?.cornerRadius = 15
        
        //set ourself as the default
        LSSetDefaultHandlerForURLScheme(scheme, currentBundleId!)
        
        //build the list of http capable apps
        if let unmanagedHttpCapableBundleIDs = LSCopyAllHandlersForURLScheme(scheme) {
            let httpCapableBundleIDs = unmanagedHttpCapableBundleIDs.takeRetainedValue() as NSArray
            for httpCapableBundleID in httpCapableBundleIDs
            {
                
                if (httpCapableBundleID as! String).lowercaseString == currentBundleId!.lowercaseString {
                    continue
                }
                
                let error: UnsafeMutablePointer<Unmanaged<CFError>?> = nil
                let unmanagedApplicationURLs = LSCopyApplicationURLsForBundleIdentifier(httpCapableBundleID as! CFString, error)
                let applicationURLs = (unmanagedApplicationURLs?.takeRetainedValue() ?? []) as NSArray
                for applicationURL in applicationURLs {
                    let cfApplicationURL = applicationURL as! NSURL
                    do {
                        var name: AnyObject? = nil
                        var icon: AnyObject? = nil
                        try cfApplicationURL.getResourceValue(&name, forKey: NSURLLocalizedNameKey)
                        try cfApplicationURL.getResourceValue(&icon, forKey: NSURLEffectiveIconKey)
                        if let nameString = name as? String, let iconImage = icon as? NSImage {
                            let applicationInfo = ApplicationInfo(bundleIdentifier: httpCapableBundleID as! String, displayName: nameString, icon: iconImage)
                            appsInfo.append(applicationInfo)
                        }
                        
                    } catch {
                    }
                }
            }
            
        }

        tableView.setDelegate(self)
        tableView.setDataSource(self)
        
        //set the timer
        countdownTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ViewController.countdown), userInfo: nil, repeats: true)
    }
    
    func countdown() {
        countdownSecondsRemaining = countdownSecondsRemaining-1
        countdownLabel.stringValue = String(countdownSecondsRemaining)
        if countdownSecondsRemaining == 0 {
            countdownTimer?.invalidate()
            countdownContainer.hidden = true
        }
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return appsInfo.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        
        let applicationInfo = appsInfo[row]
        
        switch tableColumn?.identifier ?? "" {
        case imageColumnIdentifier:
           return applicationInfo.icon
        case nameColumnIdentifier:
            return applicationInfo.displayName
        case bundleIdColumnIdentifier:
            return applicationInfo.bundleIdentifier
        default:
            return nil
        }
    }

    func tableViewSelectionDidChange(notification: NSNotification) {
        if tableView.selectedRow > -1 {
            let selectedApplicationInfo = appsInfo[tableView.selectedRow]
            NSUserDefaults.standardUserDefaults().setValue(selectedApplicationInfo.bundleIdentifier, forKey: "last_bundle_id")
            if let urlStringToOpen = NSUserDefaults.standardUserDefaults().stringForKey("url_string_to_open") {
                NSUserDefaults.standardUserDefaults().setValue(nil, forKey: "url_string_to_open")
                (NSApplication.sharedApplication().delegate as! AppDelegate).openAppWithBundleIdentifier(selectedApplicationInfo.bundleIdentifier, urlString: urlStringToOpen)
                NSApp.terminate(self)
            }
        }
        tableView.deselectAll(nil)
    }
    
}

