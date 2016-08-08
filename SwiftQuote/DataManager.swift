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
    internal static func getQuote(ticker: String, exchange: String, onCompletion: (Quote?, NSError?) -> Void) {
        // Google finance will return an array of JSON based on the ticker that was presented.
        // Throw the correct error in the event that the exchange or ticker is invalid or if the 
        // request fails.s
        let quoteUrl = String(format: GOOGLE_FINANCE_URL, exchange, ticker)
        Alamofire.request(.GET, quoteUrl)
            .validate()
            .responseString { response in
                switch response.result {
                case .Success(let data):
                    let dataJsonString = data.stringByReplacingOccurrencesOfString("// ", withString: "")
                        .stringByReplacingOccurrencesOfString("[", withString: "")
                        .stringByReplacingOccurrencesOfString("]", withString: "")
                        .stringByReplacingOccurrencesOfString("\n", withString: "")
                    
                    guard let dataJsonEncoded = dataJsonString.dataUsingEncoding(NSUTF8StringEncoding) else {
                        onCompletion(nil,NSError(domain: "error", code: 1, userInfo: nil))
                        break
                    }
                    
                    let dataJson = JSON(data: dataJsonEncoded)
                    
                    guard let quote = self.jsonToQuote(dataJson) else {
                        onCompletion(nil,NSError(domain: "error", code: 3, userInfo: nil))
                        break
                    }
                    
                    onCompletion(quote, nil)
                case .Failure(let error):
                    let err = error as NSError
                    onCompletion(nil, err)
                }
        }
    }
    
    private static func jsonToQuote(json: JSON) -> Quote? {
        guard let _e = json["e"].string,
            let _t = json["t"].string,
            let _l = json["l"].string else {
           return nil
        }
        
        return Quote(_e, _t, _l, _l)
    }
    
}