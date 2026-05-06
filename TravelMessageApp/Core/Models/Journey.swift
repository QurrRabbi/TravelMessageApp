import Foundation
import CoreLocation

struct Journey: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let startDate: Date
    var endDate: Date?
    var route: [CLLocationCoordinate2D]
    var messages: [Message]
}

extension CLLocationCoordinate2D: Codable {
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let latitude = try container.decode(Double.self)
        let longitude = try container.decode(Double.self)
        self.init(latitude: latitude, longitude: longitude)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(latitude)
        try container.encode(longitude)
    }
}
