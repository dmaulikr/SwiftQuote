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
    
    internal static let GOOGLE_FINANCE_URL:String = "https://www.google.com/finance/info?q=%@:%@"
    
    // Used By:
    // QuoteViewController
    internal static func getQuote(_ ticker: String, exchange: String, onCompletion: @escaping (Quote?, NSError?) -> Void) {
        // Google finance will return an array of JSON based on the ticker that was presented.
        // Throw the correct error in the event that the exchange or ticker is invalid or if the 
        // request fails.
        let quoteUrl = String(format: GOOGLE_FINANCE_URL, exchange, ticker)
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
    
    // Accepts a JSON input and returns an optional Quote.
    fileprivate static func jsonToQuote(_ json: JSON) -> Quote? {
        guard let _e = json["e"].string,
            let _t = json["t"].string,
            let _l = json["l"].string else {
           return nil
        }
        
        return Quote(_e, _t, _l, _l)
    }
    
}
