//
//  Created by Leonardo on 10/17/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

class OptionsWindowController: NSWindowController {

	override var windowNibName: String? {
		return "OptionsWindow"
	}

	override func windowDidLoad() {
		super.windowDidLoad()
		print("Color ",optionsTabView.window?.backgroundColor)
		optionsTabView.drawsBackground = true
		optionsTabView.window?.backgroundColor = NSColor.redColor()

	}

	@IBOutlet weak var optionsTabView: NSTabView!

	@IBAction func urlShorteningOptionsControl(sender: NSSegmentedCell) {

		let pref = PreferenceManager()
		print(pref.shortenService)
	}
}
