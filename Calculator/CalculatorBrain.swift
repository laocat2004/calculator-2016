//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Martin Mandl on 06.05.16.
//  Copyright © 2016 m2m server software gmbh. All rights reserved.
//

import Foundation

func factorial(_ op1: Double) -> Double {
    if (op1 <= 1) {
        return 1
    }
    return op1 * factorial(op1 - 1.0)
}

class CalculatorBrain {
    
    var decimalDigits: Int
    
    init(decimalDigits:Int) {
        self.decimalDigits = decimalDigits
    }
    
    fileprivate var accumulator = 0.0
    
    func setOperand(_ operand: Double) {
        accumulator = operand
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimalDigits
        descriptionAccumulator = formatter.string(from: (NSNumber(value: operand)))!
    }
    
    fileprivate var descriptionAccumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Int.max
            }
        }
    }
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAccumulator
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,
                                                    pending!.descriptionOperand != descriptionAccumulator ? descriptionAccumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    fileprivate var operations: Dictionary<String,Operation> = [
        "π" : Operation.constant(M_PI),
        "e" : Operation.constant(M_E),
        "±" : Operation.unaryOperation({ -$0 }, { "-(" + $0 + ")"}),
        "√" : Operation.unaryOperation(sqrt, { "√(" + $0 + ")"}),
        "x²" : Operation.unaryOperation({ pow($0, 2) }, { "(" + $0 + ")²"}),
        "x³" : Operation.unaryOperation({ pow($0, 3) }, { "(" + $0 + ")³"}),
        "x⁻¹" : Operation.unaryOperation({ 1 / $0 }, { "(" + $0 + ")⁻¹"}),
        "sin" : Operation.unaryOperation(sin, { "sin(" + $0 + ")"}),
        "cos" : Operation.unaryOperation(cos, { "cos(" + $0 + ")"}),
        "tan" : Operation.unaryOperation(tan, { "tan(" + $0 + ")"}),
        "sinh" : Operation.unaryOperation(sinh, { "sinh(" + $0 + ")"}),
        "cosh" : Operation.unaryOperation(cosh, { "cosh(" + $0 + ")"}),
        "tanh" : Operation.unaryOperation(tanh, { "tanh(" + $0 + ")"}),
        "ln" : Operation.unaryOperation(log, { "ln(" + $0 + ")"}),
        "log" : Operation.unaryOperation(log10, { "log(" + $0 + ")"}),
        "eˣ" : Operation.unaryOperation(exp, { "e^(" + $0 + ")"}),
        "10ˣ" : Operation.unaryOperation({ pow(10, $0) }, { "10^(" + $0 + ")"}),
        "x!" : Operation.unaryOperation(factorial, { "(" + $0 + ")!"}),
        "×" : Operation.binaryOperation(*, { $0 + " × " + $1 }, 1),
        "÷" : Operation.binaryOperation(/, { $0 + " ÷ " + $1 }, 1),
        "+" : Operation.binaryOperation(+, { $0 + " + " + $1 }, 0),
        "-" : Operation.binaryOperation(-, { $0 + " - " + $1 }, 0),
        "xʸ" : Operation.binaryOperation(pow, { $0 + " ^ " + $1 }, 2),
        "=" : Operation.equals,
        "rand" : Operation.nullaryOperation(drand48, "rand()")
    ]
    
    fileprivate enum Operation {
        case constant(Double)
        case nullaryOperation(() -> Double, String)
        case unaryOperation((Double) -> Double, (String) -> String)
        case binaryOperation((Double, Double) -> Double, (String, String) -> String, Int)
        case equals        
    }
    
    fileprivate var currentPrecedence = Int.max
    
    func performOperation(_ symbol: String) {
        if let operation = operations[symbol] {
            switch operation {
            case .constant(let value):
                accumulator = value
                descriptionAccumulator = symbol
            case .nullaryOperation(let function, let descriptionValue):
                accumulator = function()
                descriptionAccumulator = descriptionValue
            case .unaryOperation(let function, let descriptionFunction):
                accumulator = function(accumulator)
                descriptionAccumulator = descriptionFunction(descriptionAccumulator)
            case .binaryOperation(let function, let descriptionFunction, let precedence):
                executePendingBinaryOperation()
                if currentPrecedence < precedence {
                    descriptionAccumulator = "(" + descriptionAccumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator,
                                                     descriptionFunction: descriptionFunction, descriptionOperand: descriptionAccumulator)
            case .equals:
                executePendingBinaryOperation()
            }
        }
    }
    
    fileprivate func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator)
            descriptionAccumulator = pending!.descriptionFunction(pending!.descriptionOperand, descriptionAccumulator)
            pending = nil
        }
    }
    
    fileprivate var pending: PendingBinaryOperationInfo?
    
    fileprivate struct PendingBinaryOperationInfo {
        var binaryFunction: (Double, Double) -> Double
        var firstOperand: Double
        var descriptionFunction: (String, String) -> String
        var descriptionOperand: String
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
