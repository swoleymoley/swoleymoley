//
//  Achievement.swift
//  StravaZpot
//
//  Created by Tomás Ruiz López on 25/10/16.
//  Copyright © 2016 SweetZpot AS. All rights reserved.
//

import Foundation

public struct Achievement {
    public let typeID : AchievementType
    public let type : String
    public let rank : Int
}

extension Achievement : Equatable {}

public func ==(lhs : Achievement, rhs : Achievement) -> Bool {
    return  lhs.typeID == rhs.typeID &&
            lhs.type   == rhs.type &&
            lhs.rank   == rhs.rank
}
