//
//  DataManager.swift
//  SwiftQuote
//
//  Created by Jack Beoris on 8/7/16.
//  Copyright © 2016 Jack Beoris. All rights reserved.
//

import UIKit
import Foundation
import Alamofire
import SwiftyJSON

class DataManager: NSObject {
    
    internal static let GOOGLE_FINANCE_URL_FULL:String = "https://www.google.com/finance/info?q=%@:%@"
    internal static let GOOGLE_FINANCE_URL_TICKER:String = "https://www.google.com/finance/info?q=%@"
    
    // Used By:
    // QuoteViewController
    internal static func getQuote(_ ticker: String, exchange: String, onCompletion: @escaping (Quote?, NSError?) -> Void) {
        // Google finance will return an array of JSON based on the ticker that was presented.
        // Throw the correct error in the event that the exchange or ticker is invalid or if the 
        // request fails.
        let quoteUrl = formUrl(exchange: exchange, ticker: ticker)
        Alamofire.request(quoteUrl)
            .validate()
            .responseString(completionHandler: { (response) in
                switch response.result {
                case .success(let data):
                    let dataJsonString = data.replacingOccurrences(of: "// ", with: "")
                        .replacingOccurrences(of: "[", with: "")
                        .replacingOccurrences(of: "]", with: "")
                        .replacingOccurrences(of: "\n", with: "")
                    
                    guard let dataJsonEncoded = dataJsonString.data(using: String.Encoding.utf8) else {
                        onCompletion(nil,NSError(domain: "error", code: 1, userInfo: nil))
                        break
                    }
                    
                    let dataJson = JSON(data: dataJsonEncoded)
                    
                    guard let quote = self.jsonToQuote(dataJson) else {
                        onCompletion(nil,NSError(domain: "error", code: 3, userInfo: nil))
                        break
                    }
                    
                    onCompletion(quote, nil)
                case .failure(let error):
                    let err = error as NSError
                    onCompletion(nil, err)
                }
            })
    }
    
    fileprivate static func formUrl(exchange:String, ticker:String) -> String {
        let exchange = exchange.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let ticker = ticker.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if ticker != "" {
            return String(format: GOOGLE_FINANCE_URL_FULL, exchange, ticker)
        } else {
            return String(format: GOOGLE_FINANCE_URL_TICKER, ticker)
        }
    }
    
    // Accepts a JSON input and returns an optional Quote.
    fileprivate static func jsonToQuote(_ json: JSON) -> Quote? {
        let exchange = json["e"].string
        let ticker = json["t"].string
        let last = json["l"].string
        let change = json["c"].string
        
        return Quote(exchange, ticker, last, change)
    }
    
}
