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
    var ask: String
    var bid: String
    var ticker: String
    
    init(_ exchange: String?, _ ticker: String?, _ ask: String?, _ bid: String?) {
        self.exchange = exchange != nil ? exchange! : "???"
        self.ask = ask != nil ? ask! : "???"
        self.bid = bid != nil ? bid! : "???"
        self.ticker = ticker != nil ? ticker! : "???"
    }
    
 }
