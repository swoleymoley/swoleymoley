//
//  Token.swift
//  StravaZpot
//
//  Created by Tomás Ruiz López on 26/7/17.
//  Copyright © 2017 SweetZpot AS. All rights reserved.
//

import Foundation

public struct Token {
    public let value : String
    
    public init(value : String) {
        self.value = value
    }
}

extension Token : CustomStringConvertible {
    public var description : String {
        return "Bearer \(value)"
    }
}

extension Token : Equatable {}

public func ==(lhs : Token, rhs : Token) -> Bool {
    return lhs.value == rhs.value
}
