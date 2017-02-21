//
//  Quote.swift
//  SwiftQuote
//
//  Created by Jack Beoris on 8/7/16.
//  Copyright © 2016 Jack Beoris. All rights reserved.
//

import Foundation

open class Quote {
    
    var exchange: String
    var ticker: String
    var last: String
    var change: String
    
    init(_ exchange: String?, _ ticker: String?, _ last: String?, _ change: String?) {
        self.exchange = exchange ?? "???"
        self.ticker = ticker ?? "???"
        self.last = last ?? "0.00"
        self.change = change ?? "+0.00"
    }
    
 }
