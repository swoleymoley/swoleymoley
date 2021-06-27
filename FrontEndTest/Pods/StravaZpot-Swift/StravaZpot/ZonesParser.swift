//
//  ZonesParser.swift
//  StravaZpot
//
//  Created by Tomás Ruiz López on 31/10/16.
//  Copyright © 2016 SweetZpot AS. All rights reserved.
//

import Foundation
import SwiftyJSON

public class ZonesParser : Parser {
    public func from(json: JSON) -> Zones {
        return Zones(heartRate: json["heart_rate"].heartRate!,
                     power: json["power"].power!)
    }
}
