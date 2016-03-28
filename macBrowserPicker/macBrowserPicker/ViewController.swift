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
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }

    override var representedObject: AnyObject? {
        didSet {
        }
    }
    
    private func setupView() {
        
        //set ourself as the default
        LSSetDefaultHandlerForURLScheme(scheme, currentBundleId!)
        
        //build the list of http capable apps
        if let unmanagedHttpCapableBundleIDs = LSCopyAllHandlersForURLScheme(scheme) {
            let httpCapableBundleIDs = unmanagedHttpCapableBundleIDs.takeRetainedValue() as NSArray
            for httpCapableBundleID in httpCapableBundleIDs
            {
                
                if (httpCapableBundleID as! String) == currentBundleId! {
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
            LSSetDefaultHandlerForURLScheme(scheme, selectedApplicationInfo.bundleIdentifier)
        }
        tableView.deselectAll(nil)
    }
    
}

