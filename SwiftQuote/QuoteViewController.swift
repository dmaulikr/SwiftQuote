//
//  ViewController.swift
//  SwiftQuote
//
//  Created by Jack Beoris on 8/7/16.
//  Copyright © 2016 Jack Beoris. All rights reserved.
//

import UIKit
import SwiftyJSON

class QuoteViewController: UIViewController {
    
    private final let DATA_GATHERING_ERROR:String = "Error getting quote! Please make sure your exchange and ticker are valid. If they are, please try again later."
    private final let TEXT_FORMAT_ERROR:String = "Please enter a valid ticker/exchange."
    
    @IBOutlet weak var tickerTextField: UITextField!
    @IBOutlet weak var exchangeTextField: UITextField!
    @IBOutlet weak var getQuoteButton: UIButton!
    
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var tickerExchangeLabel: UILabel!
    @IBOutlet weak var askLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make status bar contrast with our dark background.
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        // Make the getQuoteButton pretty.
        getQuoteButton.layer.cornerRadius = 5
        getQuoteButton.layer.borderColor = getQuoteButton.currentTitleColor.CGColor
        getQuoteButton.layer.borderWidth = 2
        
        // Gesture recognizer to close keyboard on tap-outside.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuoteViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(animated: Bool) {
        // Hide the quote upon initial load
        toggleQuoteViewVisibility(true)
        toggleLoadingAnimation(false)
    }

    @IBAction func getQuoteAction(sender: AnyObject) {
        if let _exchange = exchangeTextField.text,
            let _ticker = tickerTextField.text {
            self.toggleLoadingAnimation(true)
            self.toggleQuoteViewVisibility(true)
            
            DataManager.getQuote(_ticker, exchange: _exchange, onCompletion: { (quote, error) in
                if error == nil && quote != nil {
                    self.displayQuote(quote!)
                    self.toggleQuoteViewVisibility(false)
                } else {
                    print(error)
                    self.displayErrorMessage(self.DATA_GATHERING_ERROR)
                }
                
                self.clearTextFieldText()
                self.toggleLoadingAnimation(false)
            })
        } else {
            self.displayErrorMessage(TEXT_FORMAT_ERROR)
        }
    }
    
    private func displayQuote(quote: Quote) {
        askLabel.text = quote.ask
        bidLabel.text = quote.bid
        tickerExchangeLabel.text = String(format: "%@:%@", quote.exchange, quote.ticker)
    }
    
    private func displayErrorMessage(error:String) {
        let alertController = UIAlertController(title: "Error!", message:
            error, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    private func clearTextFieldText() {
        tickerTextField.text = ""
        exchangeTextField.text = ""
    }
    
    private func toggleLoadingAnimation(showAnimation:Bool) {
        if showAnimation {
            activityIndicator.hidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.hidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    private func toggleQuoteViewVisibility(hidden:Bool) {
        quoteView.hidden = hidden
    }
    
    
    @objc private func tap(gesture: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}