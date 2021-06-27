//
//  AthleteParser.swift
//  StravaZpot
//
//  Created by Tomás Ruiz López on 1/11/16.
//  Copyright © 2016 SweetZpot AS. All rights reserved.
//

import Foundation
import SwiftyJSON

public class AthleteParser : Parser {
    public func from(json: JSON) -> Athlete {
        return Athlete(id: json["id"].int!,
                       resourceState: json["resource_state"].resourceState!,
                       firstName: json["firstname"].string,
                       lastName: json["lastname"].string,
                       profileMedium: json["profile_medium"].string,
                       profile: json["profile"].string,
                       city: json["city"].string,
                       state: json["state"].string,
                       country: json["country"].string,
                       sex: json["sex"].gender,
                       friend: json["friend"].friendStatus,
                       follower: json["follower"].friendStatus,
                       isPremium: json["premium"].bool,
                       createdAt: json["created_at"].date,
                       updatedAt: json["updated_at"].date,
                       followerCount: json["follower_count"].int,
                       friendCount: json["friend_count"].int,
                       mutualFriendCount: json["mutual_friend_count"].int,
                       athleteType: json["athlete_type"].athleteType,
                       datePreference: json["date_preference"].string,
                       measurementPreference: json["measurement_preference"].measurementPreference,
                       email: json["email"].string,
                       ftp: json["ftp"].int,
                       weight: json["weight"].double,
                       clubs: json["clubs"].clubArray,
                       bikes: json["bikes"].gearArray,
                       shoes: json["shoes"].gearArray)
    }
    
}
