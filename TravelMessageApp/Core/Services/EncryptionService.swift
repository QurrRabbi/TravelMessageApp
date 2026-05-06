import Foundation
import CryptoKit

protocol EncryptionServiceProtocol {
    func encrypt(_ data: Data, key: SymmetricKey) throws -> Data
    func decrypt(_ data: Data, key: SymmetricKey) throws -> Data
    func generateKey() -> SymmetricKey
}

final class EncryptionService: EncryptionServiceProtocol {
    func encrypt(_ data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: key)
        guard let combined = sealedBox.combined else {
            throw EncryptionError.sealingFailed
        }
        return combined
    }

    func decrypt(_ data: Data, key: SymmetricKey) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: key)
    }

    func generateKey() -> SymmetricKey {
        SymmetricKey(size: .bits256)
    }
}

enum EncryptionError: Error {
    case sealingFailed
    case decryptionFailed
}
