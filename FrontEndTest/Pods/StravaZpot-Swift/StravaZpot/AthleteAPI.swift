//
//  AthleteAPI.swift
//  StravaZpot
//
//  Created by Tomás Ruiz López on 2/11/16.
//  Copyright © 2016 SweetZpot AS. All rights reserved.
//

import Foundation

public class AthleteAPI {
    private let client : HTTPClient
    
    public init(client : HTTPClient) {
        self.client = client
    }
    
    public func retrieveCurrentAthlete() -> GetCurrentAthleteRequest {
        return GetCurrentAthleteRequest(client: client)
    }
    
    public func retrieveAthlete(withID id: Int) -> RetrieveAthleteRequest {
        return RetrieveAthleteRequest(client: client, id: id)
    }
    
    public func updateCurrentAthlete(withCity city : String? = nil, withState state : String? = nil, withCountry country : String? = nil, withSex sex : Gender? = nil, withWeight weight : Double? = nil) -> UpdateAthleteRequest {
        return UpdateAthleteRequest(client: client, city: city, state: state, country: country, sex: sex, weight: weight)
    }
    
    public func getAthleteZones() -> GetAthleteZonesRequest {
        return GetAthleteZonesRequest(client: client)
    }
    
    public func getTotalsAndStats(withID id : Int) -> GetTotalsAndStatsRequest {
        return GetTotalsAndStatsRequest(client: client, id: id)
    }
    
    public func listAthleteKOMS(withID id : Int) -> ListAthleteKOMSRequest {
        return ListAthleteKOMSRequest(client: client, id: id)
    }
}
