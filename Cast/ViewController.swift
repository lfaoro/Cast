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
        print("ViewDidLoad Called") //prints ViewDidLoad Called
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

class DraggedView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.registerForDraggedTypes(pasteboardTypes)
    }
    

}

extension DraggedView {
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        return NSDragOperation.Copy
        
    }
}
