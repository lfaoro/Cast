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

    override func viewDidLoad() {
        super.viewDidLoad()
        print("ViewDidLoad Called")

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

