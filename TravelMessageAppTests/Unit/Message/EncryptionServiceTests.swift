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

    func test_generateKey_producesUniqueKeys() {
        let a = sut.generateKey()
        let b = sut.generateKey()
        XCTAssertNotEqual(a.withUnsafeBytes { Data($0) }, b.withUnsafeBytes { Data($0) })
    }

    func test_encrypt_sameInputTwice_producesDifferentCiphertext() throws {
        let original = "Repeated message".data(using: .utf8)!
        let key = sut.generateKey()

        let first = try sut.encrypt(original, key: key)
        let second = try sut.encrypt(original, key: key)

        // AES-GCM uses a random nonce per seal, so ciphertexts must differ.
        XCTAssertNotEqual(first, second)
    }

    func test_decrypt_withWrongKey_throws() throws {
        let original = "Top secret".data(using: .utf8)!
        let encrypted = try sut.encrypt(original, key: sut.generateKey())

        XCTAssertThrowsError(try sut.decrypt(encrypted, key: sut.generateKey()))
    }

    func test_decrypt_tamperedCiphertext_throws() throws {
        let original = "Authenticated payload".data(using: .utf8)!
        let key = sut.generateKey()
        var encrypted = try sut.encrypt(original, key: key)

        // Flip the final byte to break the GCM authentication tag.
        encrypted[encrypted.count - 1] ^= 0xFF

        XCTAssertThrowsError(try sut.decrypt(encrypted, key: key))
    }
}
