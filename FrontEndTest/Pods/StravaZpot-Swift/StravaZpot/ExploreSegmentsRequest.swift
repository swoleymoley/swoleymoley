//
//  ExploreSegmentsRequest.swift
//  StravaZpot
//
//  Created by Tomás Ruiz López on 7/11/16.
//  Copyright © 2016 SweetZpot AS. All rights reserved.
//

import Foundation

public class ExploreSegmentsRequest : GetRequest<ExploreResult> {
    private var parameters : [String : Any] = [:]
    
    init(client : HTTPClient, bounds : Bounds, activityType : ExploreType?, minCategory : Int?, maxCategory : Int?) {
        parameters["bounds"] = bounds.description
        parameters["activity_type"] = activityType?.rawValue
        parameters["min_cat"] = minCategory
        parameters["max_cat"] = maxCategory
        super.init(client: client, url: "segments/explore", parse: { $0.exploreResult })
    }
    
    override func getParameters() -> [String : Any] {
        return parameters
    }
}
