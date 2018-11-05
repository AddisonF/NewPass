//
//  PasswordGenerator.swift
//  NewPass
//
//  Created by Addison Francisco on 7/17/18.
//  Copyright © 2018 Addison Francisco. All rights reserved.
//

import Foundation

struct Password {
    
    static func randomPassword(with attributes: [PasswordAttribute], length: Int) -> String {
        // Create an initial string of password characters based on attributes
        let passwordString = constructedPasswordString(using: attributes)
        // Randomize password string characters
        let randomPassword = randomize(string: passwordString, length: length, attributes: attributes)
        return randomPassword
    }
    
    private static func constructedPasswordString(using attributes: [PasswordAttribute]) -> String {
        var constructedPasswordString = ""
        for attribute in attributes {
            let alphabet = PasswordAttribute.containsAlphabet.rawValue
            let uppercasedAlphabet = PasswordAttribute.containsUppercaseLetters.rawValue
            let numbers = PasswordAttribute.containsNumbers.rawValue
            let symbols = PasswordAttribute.containsSymbols.rawValue
            
            switch attribute {
            case .containsNumbers:
                constructedPasswordString += randomize(string: numbers)
            case .containsSymbols:
                constructedPasswordString += randomize(string: symbols)
            case .containsAlphabet:
                constructedPasswordString += randomize(string: alphabet)
            case .containsUppercaseLetters:
                constructedPasswordString += randomize(string: uppercasedAlphabet)
            }
        }
        return constructedPasswordString
    }
    
    private static func randomize(string: String, length: Int = 26, attributes: [PasswordAttribute] = []) -> String {
        var randomString: String = ""
        
        while randomString.count < length {
            let randomValue = arc4random_uniform(UInt32(string.count))
            randomString += "\(string[string.index(string.startIndex, offsetBy: Int(randomValue))])"
        }
        
        if !allAttributeCharsPresent(for: randomString, attributes: attributes) && !attributes.isEmpty {
            randomString = randomize(string: string, length: length, attributes: attributes)
        }
        return randomString
    }
    
    private static func allAttributeCharsPresent(for passwordString: String, attributes: [PasswordAttribute]) -> Bool {
        for attribute in attributes {
            // TODO: This is repetative. Maybe can clean this up a little
            switch attribute {
            case .containsAlphabet:
                if passwordString.rangeOfCharacter(from: PasswordCharacterSet.alphabet) != nil {
                    continue
                } else { return false }
            case .containsNumbers:
                if passwordString.rangeOfCharacter(from: PasswordCharacterSet.numbers) != nil {
                    continue
                } else { return false }
            case .containsSymbols:
                if passwordString.rangeOfCharacter(from: PasswordCharacterSet.symbols) != nil {
                    continue
                } else { return false }
            case .containsUppercaseLetters:
                if passwordString.rangeOfCharacter(from: PasswordCharacterSet.uppercaseAlphabet) != nil {
                    continue
                } else { return false }
            }
        }
        return true
    }
}
