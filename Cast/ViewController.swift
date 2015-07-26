//
//  ViewController.swift
//  Cast
//
//  Created by Leonardo on 18/07/2015.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet var firstView: DraggedView!
	let apiCall = LFAPICalls()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad Called") //prints ViewDidLoad Called

        apiCall.delegate = self
        apiCall.shorten("http://xborderconsulting.com/xborder/")
        
    }
    
    override var representedObject: AnyObject? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}


extension ViewController: LFAPICallsDelegate {
	func shortened(URL: NSURL?) {
		print("shortened called!")
		print(URL!)
	}
}


class DraggedView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.registerForDraggedTypes(pasteboardTypes)
    }

    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        return NSDragOperation.Copy
        
    }
}

