//
//  Errors.swift
//  Cast
//
//  Created by Leonardo on 10/21/15.
//  Copyright © 2015 Leonardo Faoro. All rights reserved.
//

import Foundation


public enum ConnectionError: ErrorType {
	case InvalidData(String), NoResponse(String), NotAuthenticated(String), StatusCode(Int)
}