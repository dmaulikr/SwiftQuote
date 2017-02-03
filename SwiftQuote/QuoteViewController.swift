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
    
    // Static strings.
    fileprivate final let DATA_GATHERING_ERROR:String = "Error getting quote! Please make sure your exchange and ticker are valid. If they are, please try again later."
    fileprivate final let TEXT_FORMAT_ERROR:String = "Please enter a valid ticker/exchange."
    fileprivate final let DEFAULT_EXCHANGE:String = "NASDAQ"
    fileprivate final let DEFAULT_TICKER:String = "AAPL"
    
    // View elements.
    @IBOutlet weak var entryView: UIView!
    @IBOutlet weak var getQuoteButton: UIButton!
    @IBOutlet weak var tickerTextField: UITextField!
    @IBOutlet weak var exchangeTextField: UITextField!
    @IBOutlet weak var quoteView: UIView!
    @IBOutlet weak var tickerExchangeLabel: UILabel!
    @IBOutlet weak var askLabel: UILabel!
    @IBOutlet weak var bidLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // View constraints.
    @IBOutlet weak var entryViewLeadingContstraint: NSLayoutConstraint!
    @IBOutlet weak var entryViewVerticalContraint: NSLayoutConstraint!
    @IBOutlet weak var quoteViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var quoteViewVerticalConstraint: NSLayoutConstraint!
    
    // Update constraints on rotation.
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        updateConstraints()
    }
    
    // Update constraints on initial subview layout.
    override func viewDidLayoutSubviews() {
        updateConstraints()
    }
    
    // Update the constraints of the main two subviews based on
    // the current device orientation.
    fileprivate func updateConstraints() {
        let padding:CGFloat = 16.0
        let viewWidth = self.view.frame.size.width
        let viewHeight = self.view.frame.size.height
        
        let entryViewWidth = entryView.frame.width
        let entryViewHeight = entryView.frame.height
        let quoteViewWidth = quoteView.frame.width
        let quoteViewHeight = quoteView.frame.height
        
        switch UIApplication.shared.statusBarOrientation {
        case .portrait, .portraitUpsideDown, .unknown:
            entryViewLeadingContstraint.constant = ((viewWidth - entryViewWidth) / 2) - padding
            entryViewVerticalContraint.constant = (((viewHeight / 2) - entryViewHeight) / 2) - padding
            
            quoteViewLeadingConstraint.constant = ((viewWidth - quoteViewWidth) / 2) - padding
            quoteViewVerticalConstraint.constant = ((((viewHeight / 2) - quoteViewHeight) / 2) + (viewHeight / 2)) - padding
            break
        case .landscapeLeft, .landscapeRight:
            entryViewVerticalContraint.constant = ((viewHeight - entryViewHeight) / 2) - padding
            entryViewLeadingContstraint.constant = (((viewWidth / 2) - entryViewWidth) / 2) - padding
            
            quoteViewVerticalConstraint.constant = ((viewHeight - quoteViewHeight) / 2) - padding
            quoteViewLeadingConstraint.constant = ((((viewWidth / 2) - quoteViewWidth) / 2) + (viewWidth / 2)) - padding
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make status bar contrast with our dark background.
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Make the getQuoteButton pretty.
        getQuoteButton.layer.cornerRadius = 5
        getQuoteButton.layer.borderColor = getQuoteButton.currentTitleColor.cgColor
        getQuoteButton.layer.borderWidth = 2
        
        // Gesture recognizer to close keyboard on tap-outside.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuoteViewController.tap(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Hide the quote upon initial load
        toggleQuoteViewVisibility(true)
        toggleLoadingAnimation(false)
        
        // Load in default data and set correpsonding placeholder text.
        exchangeTextField.placeholder = DEFAULT_EXCHANGE
        tickerTextField.placeholder = DEFAULT_TICKER
        fetchQuoteData(DEFAULT_TICKER, _exchange: DEFAULT_EXCHANGE)
    }

    // Called from UI. Initializes quote data fetching task.
    @IBAction func getQuoteAction(_ sender: AnyObject) {
        if let _exchange = exchangeTextField.text,
            let _ticker = tickerTextField.text {
            self.toggleLoadingAnimation(true)
            self.toggleQuoteViewVisibility(true)
            
            fetchQuoteData(_ticker, _exchange: _exchange)
        } else {
            self.displayErrorMessage(TEXT_FORMAT_ERROR)
        }
        
        closeKeyboard()
    }
    
    // Calls the DataManager to gather quote data for display.
    fileprivate func fetchQuoteData(_ _ticker:String, _exchange:String) {
        DataManager.getQuote(_ticker, exchange: _exchange, onCompletion: { (quote, error) in
            if error == nil && quote != nil {
                self.displayQuote(quote!)
                self.toggleQuoteViewVisibility(false)
            } else {
                self.displayErrorMessage(self.DATA_GATHERING_ERROR)
            }
            
            self.clearTextFieldText()
            self.toggleLoadingAnimation(false)
        })
    }
    
    // Displays a quote in the UI.
    fileprivate func displayQuote(_ quote: Quote) {
        askLabel.text = quote.ask
        bidLabel.text = quote.bid
        tickerExchangeLabel.text = String(format: "%@ (%@)", quote.ticker, quote.exchange)
    }
    
    // Displays an dismissable error message.
    fileprivate func displayErrorMessage(_ error:String) {
        let alertController = UIAlertController(title: "Error!", message:
            error, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default,handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    // Clears the textfields for more input.
    fileprivate func clearTextFieldText() {
        tickerTextField.text = ""
        exchangeTextField.text = ""
    }
    
    // Shows/Hides loading animation during/after data fetching tasks.
    fileprivate func toggleLoadingAnimation(_ showAnimation:Bool) {
        if showAnimation {
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
        } else {
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    // Shows/Hides quoteView during/after data fetching tasks.
    fileprivate func toggleQuoteViewVisibility(_ hidden:Bool) {
        quoteView.isHidden = hidden
    }
    
    // Dimisses keyboard upon tapping the UI outside of the keyboard itself.
    @objc fileprivate func tap(_ gesture: UITapGestureRecognizer) {
        closeKeyboard()
    }
    
    // Dimisses the keyboard.
    fileprivate func closeKeyboard() {
        view.endEditing(true)
    }
    
}
