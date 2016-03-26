//
//  VerticallyAlignedTextFieldCell.swift
//  macBrowserPicker
//
//  Created by Antonino Urbano on 2016-03-26.
//  Copyright © 2016 Antonino Urbano. All rights reserved.
//

import Cocoa

class VerticallyAlignedTextFieldCell: NSTextFieldCell {

    override func titleRectForBounds(theRect: NSRect) -> NSRect {
        let stringHeight = self.attributedStringValue.size().height
        var titleRect = super.titleRectForBounds(theRect)
        titleRect.origin.y = theRect.origin.y + (theRect.size.height - stringHeight)/2
        return super.titleRectForBounds(titleRect)
    }

    override func drawInteriorWithFrame(cellFrame: NSRect, inView controlView: NSView) {
        super.drawInteriorWithFrame(self.titleRectForBounds(cellFrame), inView: controlView)
    }

}
