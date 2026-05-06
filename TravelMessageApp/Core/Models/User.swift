import Foundation

struct User: Codable, Identifiable, Equatable {
    let id: String
    let email: String
    let displayName: String
    let profileImageURL: URL?
}
