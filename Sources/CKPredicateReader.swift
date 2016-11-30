//
//  CKPredicateReader.swift
//  OpenCloudKit
//
//  Created by Benjamin Johnson on 19/07/2016.
//
//

import Foundation

struct CKPredicateReader {
    
    typealias Index = Int
    typealias IndexDistance = Int
    let source: ASCIISource
    static let numberFormatter = NumberFormatter()
    
    
    init(string: String) {
        source = ASCIISource(buffer: string)
    }
    
    struct ASCIISource {
        let buffer: String
        let position: Int = 0
        let step = 1
        
        init(buffer: String) {
            self.buffer = buffer
        }
        
        func hasNext(_ input: Index) -> Bool {
            return input + step <= buffer.characters.count
        }
        
        func takeCharacter(_ input: Index) -> (Character, Index)? {
            guard hasNext(input) else {
                return nil
            }
            
            let ascii = buffer[buffer.index(buffer.startIndex, offsetBy: input)]
            return (ascii, input + step)
        }
        
        func takeString(begin: Index, end: Index) -> String {
            return buffer[buffer.index(buffer.startIndex, offsetBy: begin)..<buffer.index(buffer.startIndex, offsetBy: end)]
        }
    }
    
    struct IndexPosition {
        var chunkIndex: Index
        var currentIndex: Index
        
        mutating func advance() {
            currentIndex += 1
        }
        
        mutating func set(_ index: Index) {
            currentIndex = index
            chunkIndex = currentIndex
        }
    }
    
    func parseLocation(index: Index) throws -> CKLocationCoordinate2D? {
        
        var chunkIndex = index
        var currentIndex = chunkIndex
        var latitude: Double?
        while source.hasNext(currentIndex) {
            guard let (ascii, index) = source.takeCharacter(currentIndex) else {
                currentIndex += source.step
                continue
            }
            
            switch ascii {
            case "<":
                currentIndex += 1
                chunkIndex = currentIndex
            case ">":
                if let longitudeValue = takeValue(begin: chunkIndex, end: currentIndex) as? NSNumber, let latitude = latitude {
                    return CKLocationCoordinate2D(latitude: latitude, longitude: longitudeValue.doubleValue)
                } else {
                    return nil
                }
            case "+":
                currentIndex += 1
                chunkIndex = currentIndex
            case ",":
                if let latitudeValue = takeValue(begin: chunkIndex, end: currentIndex) as? NSNumber {
                    latitude = latitudeValue.doubleValue
                    currentIndex += 1
                    chunkIndex = currentIndex
                } else {
                    return nil
                }
            default:
                currentIndex = index
                
            }
        }
        
        return nil
    }
    
    func consumeWhitespace(_ input: Index) -> Index? {
        var index = input
        while let (char, nextIndex) = source.takeCharacter(index)  , char == " " {
            index = nextIndex
        }
        return index
    }
    
    func parseLocationExpression(_ input: Index) throws -> (fieldName: String, coordinate: CKLocationCoordinate2D)? {
        
        let locationFunction = try parseFunction(input)
        guard locationFunction.0 == "distanceToLocation:fromLocation:" else {
            return nil
        }
        
        guard let fieldName = locationFunction.parameters.first as? String, let locationData = locationFunction.parameters.last as? String else {
            return nil
        }
        let locationReader = CKPredicateReader(string: locationData)
        if let coordinate = try locationReader.parseLocation(index: 0) {
            return (fieldName, coordinate)
        }
        
        return nil
        
    }
    
    func parseFunction(_ input: Index) throws -> (String, parameters: [Any]) {
        
        var chunkIndex = input
        var currentIndex = chunkIndex
        
        var functionName: String = ""
        var parameters: [Any] = []
        var inBracket: Int = 0
        
        while source.hasNext(currentIndex) {
            guard let (ascii, index) = source.takeCharacter(currentIndex) else {
                currentIndex += source.step
                continue
            }
            
            switch ascii {
            case "(":
                
                if (inBracket == 0) {
                    functionName = source.takeString(begin: chunkIndex, end: currentIndex)
                    currentIndex += 1
                    chunkIndex = currentIndex
                } else {
                    currentIndex += 1
                }
                
                inBracket += 1
                
            case ")":
                inBracket -= 1
                // Add parameter
                if (inBracket == 0) {
                    if let value = takeValue(begin: chunkIndex, end: currentIndex) {
                        parameters.append(value)
                    }
                    currentIndex += 1
                    chunkIndex = currentIndex
                } else {
                    currentIndex += 1
                }
                
            case "<":
                inBracket += 1
                currentIndex += 1
            case ">":
                inBracket -= 1
                currentIndex += 1
            case "\"":
                currentIndex += 1
                let string = try parseString(currentIndex)!
                parameters.append(string.0.bridge())
                
                currentIndex = string.1
                chunkIndex = currentIndex
            case ",":
                if(inBracket == 1) {
                    // Add Parameter
                    if let value = takeValue(begin: chunkIndex, end: currentIndex) {
                        parameters.append(value)
                    }
                    currentIndex += 1
                    currentIndex = consumeWhitespace(currentIndex) ?? currentIndex
                    chunkIndex = currentIndex
                    
                } else {
                    currentIndex += 1
                    
                }
                
            default:
                currentIndex = index
            }
        }
        
        return (functionName, parameters)
    }
    
    func takeValue(begin: Index, end: Index) -> Any? {
        let token = source.takeString(begin: begin, end: end)
        if !token.isEmpty {
       
            let number = CKPredicateReader.numberFormatter.number(from: token)
            
            
            if let number = number {
                return number
            } else {
                return token.bridge()
            }
        } else {
            return nil
        }
    }
    
    func parse(_ input: Index) throws -> [String] {
        var chunkIndex = input
        var currentIndex = chunkIndex
        var tokens: [String] = []
        var inBracket: Int = 0
        while source.hasNext(currentIndex) {
            
            
            guard let (ascii, index) = source.takeCharacter(currentIndex) else {
                currentIndex += source.step
                continue
            }
                        
            switch ascii {
            case "\"":
                currentIndex = index
                if (inBracket == 0) {
                    if let parse = try parseString(currentIndex) {
                        let string = parse.0
                        currentIndex = parse.1
                        chunkIndex = parse.1
                        tokens.append(string)
                    }
                }
            case "(":
                inBracket += 1
                currentIndex = index
            case ")":
                inBracket -= 1
                currentIndex = index
            case " ":
                if (inBracket == 0) {
                    let token = source.takeString(begin: chunkIndex, end: currentIndex)
                    if !token.isEmpty {
                        tokens.append(token)
                    }
                    
                    currentIndex = index
                    chunkIndex = currentIndex
                } else {
                    currentIndex = index
                }
                
            default:
                currentIndex = index
            }
            
            
        }
        
        let token = source.takeString(begin: chunkIndex, end: currentIndex)
        if !token.isEmpty {
            tokens.append(token)
        }
        
        return tokens
    }
    
    func parseString(_ input: Index) throws -> (String, Index)? {
        
        let chunkIndex = input
        var currentIndex = chunkIndex
        
        var output: String = ""
        while source.hasNext(currentIndex) {
            guard let (ascii, index) = source.takeCharacter(currentIndex) else {
                currentIndex += source.step
                continue
            }
            
            switch ascii {
            case "\"":
                output += source.takeString(begin: chunkIndex, end: currentIndex)
                return(output,index)
            default:
                currentIndex = index
            }
        }
        
        throw NSError(domain: NSCocoaErrorDomain, code: CocoaError.propertyListReadCorrupt.rawValue, userInfo: [
            "NSDebugDescription" : "Invalid escape sequence at position \(currentIndex)"
            ])
    }
}
