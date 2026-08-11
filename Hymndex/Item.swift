//
//  Item.swift
//  Hymndex
//
//  Created by Noah Rosamilia on 8/11/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
