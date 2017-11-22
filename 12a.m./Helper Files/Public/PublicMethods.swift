//
//  PublicMethods.swift
//  12a.m.
//
//  Created by Nick Reichard on 11/22/17.
//  Copyright © 2017 Nick Reichard. All rights reserved.
//

import Foundation

infix operator ???: NilCoalescingPrecedence
public func ???<T>(optional: T?, defaultValue: @autoclosure () -> String) -> String {
    return optional.map { String(describing: $0) } ?? defaultValue()
}
