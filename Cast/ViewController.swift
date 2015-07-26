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

		//take a string, 
		apiCall.shortenAsync("//chris.com", successBlock: {
			if let url = $0 {
				print("completion block \(url)")
			} else {
				//give some opportunity to respond to failure
			}

			})
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

