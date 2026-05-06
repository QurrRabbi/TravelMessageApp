import Foundation
import CoreLocation

struct Message: Codable, Identifiable {
    let id: String
    let journeyId: String
    let authorId: String
    let content: String
    let photoURLs: [URL]
    let coordinate: CLLocationCoordinate2D
    let proximityRadiusMetres: Double
    let encryptedShareLink: String?
    let createdAt: Date

    static let defaultProximityRadiusMetres: Double = 50.0
}
