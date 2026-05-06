import XCTest
import CryptoKit
@testable import TravelMessageApp

final class EncryptionServiceTests: XCTestCase {
    private var sut: EncryptionService!

    override func setUp() {
        super.setUp()
        sut = EncryptionService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_encryptThenDecrypt_returnsOriginalData() throws {
        let original = "Hello, TravelMessageApp!".data(using: .utf8)!
        let key = sut.generateKey()

        let encrypted = try sut.encrypt(original, key: key)
        let decrypted = try sut.decrypt(encrypted, key: key)

        XCTAssertEqual(original, decrypted)
    }

    func test_encrypt_producesDataDifferentFromInput() throws {
        let original = "Test message".data(using: .utf8)!
        let key = sut.generateKey()

        let encrypted = try sut.encrypt(original, key: key)

        XCTAssertNotEqual(original, encrypted)
    }

    func test_generateKey_produces256BitKey() {
        let key = sut.generateKey()
        XCTAssertEqual(key.bitCount, 256)
    }
}
