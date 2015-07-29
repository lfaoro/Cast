//
//  Dragging.swift
//  Cast
//
//  Created by Chris Patrick Schreiner on 26/07/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Foundation
import AppKit


//MARK:- (Pr) NSDraggingDestination implementation

class DraggedView: NSView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.registerForDraggedTypes(pasteboardTypes)
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        
        return NSDragOperation.Copy
        
    }
}

extension NSStatusBarButton {

	public override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
		Swift.print("Called: draggingEntered")
		return NSDragOperation.Copy

	}

	public override func draggingExited(sender: NSDraggingInfo?) {
		Swift.print("Called: draggingExited")

	}

	public override func draggingEnded(sender: NSDraggingInfo?) {
		Swift.print("Called: draggingEnded")
		let pasteBoard = sender?.draggingPasteboard()
		for item in pasteBoard!.pasteboardItems! {
			if let item = item.stringForType(NSPasteboardTypeString) {
				Swift.print("Pasteboard Contents:")
				Swift.print(item)
			}
		}
	}

}

