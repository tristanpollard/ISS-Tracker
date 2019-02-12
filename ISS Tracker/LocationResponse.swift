//
// Created by Tristan Pollard on 2019-02-12.
// Copyright (c) 2019 Tristan Pollard. All rights reserved.
//

import Foundation

struct LatLong: Codable{
    var latitude: Double
    var longitude: Double

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let latStr = try values.decode(String.self, forKey: .latitude)
        let longStr = try values.decode(String.self, forKey: .longitude)
        latitude = Double(latStr)!
        longitude = Double(longStr)!
    }
}

struct ISSLocationResponse: Codable {
    var message: String
    var date: Date
    var position: LatLong

    enum CodingKeys: String, CodingKey {
        case message = "message"
        case date = "timestamp"
        case position = "iss_position"
    }
}