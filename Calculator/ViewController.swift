//
//  ViewController.swift
//  Calculator
//
//  Created by Martin Mandl on 05.05.16.
//  Copyright © 2016 m2m server software gmbh. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet fileprivate weak var display: UILabel!
    
    @IBOutlet fileprivate weak var history: UILabel!
    
    fileprivate var userIsInTheMiddleOfTyping = false {
        didSet {
            if !userIsInTheMiddleOfTyping {
                userIsInTheMiddleOfFloatingPointNummer = false
            }
        }
    }
    fileprivate var userIsInTheMiddleOfFloatingPointNummer = false
    
    fileprivate let decimalSeparator = NumberFormatter().decimalSeparator!
    
    fileprivate struct Constants {
        static let DecimalDigits = 6
    }
    
    
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
        var digit = sender.currentTitle!
        
        if digit == decimalSeparator {
            if userIsInTheMiddleOfFloatingPointNummer {
                return
            }
            if !userIsInTheMiddleOfTyping {
                digit = "0" + decimalSeparator
            }
            userIsInTheMiddleOfFloatingPointNummer = true
        }
        
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTyping = true
        }
    }
    
    fileprivate var displayValue: Double? {
        get {
            if let text = display.text, let value = NumberFormatter().number(from: text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = Constants.DecimalDigits
                display.text = formatter.string(from: NSNumber(value: value))
                history.text = brain.description + (brain.isPartialResult ? " …" : " =")
            } else {
                display.text = "0"
                history.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    fileprivate var brain = CalculatorBrain(decimalDigits: Constants.DecimalDigits)
    
    @IBAction fileprivate func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
    }
    
    @IBAction func backSpace(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            if var text = display.text {
                text.remove(at: text.characters.index(before: text.endIndex))
                if text.isEmpty {
                    text = "0"
                    userIsInTheMiddleOfTyping = false
                }
                display.text = text
            }
        }
    }
    
    @IBAction func clearEverything(_ sender: UIButton) {
        brain = CalculatorBrain(decimalDigits: Constants.DecimalDigits)
        displayValue = nil
    }
    
    fileprivate func adjustButtonLayout(_ view: UIView, portrait: Bool) {
        for subview in view.subviews {
            if subview.tag == 1 {
                subview.isHidden = portrait
            } else if subview.tag == 2 {
                subview.isHidden = !portrait
            }
            if let button = subview as? UIButton {
                button.setBackgroundColor(UIColor.black, forState: .highlighted)
                if button.tag == 3 {
                    button.setTitle(decimalSeparator, for: UIControlState())
                }
            } else if let stack = subview as? UIStackView {
                adjustButtonLayout(stack, portrait: portrait);
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        adjustButtonLayout(view, portrait: traitCollection.horizontalSizeClass == .compact && traitCollection.verticalSizeClass == .regular)
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        adjustButtonLayout(view, portrait: newCollection.horizontalSizeClass == .compact && newCollection.verticalSizeClass == .regular)
    }
    
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, forState state: UIControlState) {
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext();
        color.setFill()
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        setBackgroundImage(image, for: state);
    }
}

