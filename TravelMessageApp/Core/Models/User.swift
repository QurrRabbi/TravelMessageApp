import Foundation

struct User: Codable, Identifiable {
    let id: String
    let email: String
    let displayName: String
    let profileImageURL: URL?
}
