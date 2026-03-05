import Foundation
import CryptoKit

@MainActor
class PasswordVault {
    static let shared = PasswordVault()
    
    private let keychainHelper = KeychainHelper.shared
    private let saltKey = "CopyCat.Salt"
    
    private init() {}
    
    func savePassword(_ password: String, for connectionId: UUID) throws {
        let salt = try getOrCreateSalt()
        let encrypted = try encryptPassword(password, salt: salt)
        try keychainHelper.savePassword(encrypted, for: connectionId.uuidString)
    }
    
    func getPassword(for connectionId: UUID) throws -> String? {
        guard let encrypted = try keychainHelper.getPassword(for: connectionId.uuidString) else {
            return nil
        }
        let salt = try getOrCreateSalt()
        return try decryptPassword(encrypted, salt: salt)
    }
    
    func deletePassword(for connectionId: UUID) throws {
        try keychainHelper.deletePassword(for: connectionId.uuidString)
    }
    
    private func getOrCreateSalt() throws -> Data {
        if let existingSalt = try keychainHelper.getPassword(for: saltKey) {
            return Data(base64Encoded: existingSalt)!
        }
        
        var salt = Data(count: 16)
        _ = salt.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 16, $0.baseAddress!)
        }
        
        let saltBase64 = salt.base64EncodedString()
        try keychainHelper.savePassword(saltBase64, for: saltKey)
        
        return salt
    }
    
    private func encryptPassword(_ password: String, salt: Data) throws -> String {
        let passwordData = password.data(using: .utf8)!
        
        let key = try deriveKey(from: salt)
        
        let nonce = AES.GCM.Nonce()
        let sealedBox = try AES.GCM.seal(passwordData, using: key, nonce: nonce)
        
        let combined = nonce + sealedBox.ciphertext + sealedBox.tag
        return combined.base64EncodedString()
    }
    
    private func decryptPassword(_ encrypted: String, salt: Data) throws -> String {
        let combined = Data(base64Encoded: encrypted)!
        
        let nonce = combined.prefix(12)
        let ciphertext = combined.dropFirst(12).dropLast(16)
        let tag = combined.suffix(16)
        
        let key = try deriveKey(from: salt)
        
        let sealedBox = try AES.GCM.SealedBox(nonce: AES.GCM.Nonce(data: nonce), ciphertext: ciphertext, tag: tag)
        let decrypted = try AES.GCM.open(sealedBox, using: key)
        
        return String(data: decrypted, encoding: .utf8)!
    }
    
    private func deriveKey(from salt: Data) throws -> SymmetricKey {
        let masterKeyData = try getOrCreateMasterKey()
        let masterKey = SymmetricKey(data: masterKeyData)
        
        let info = "CopyCat.PasswordVault".data(using: .utf8)!
        let derivedKey = HKDF<SHA256>.deriveKey(inputKeyMaterial: masterKey, salt: salt, info: info, outputByteCount: 32)
        
        return derivedKey
    }
    
    private func getOrCreateMasterKey() throws -> Data {
        let masterKeyKey = "CopyCat.MasterKey"
        
        if let existingKey = try keychainHelper.getPassword(for: masterKeyKey) {
            return Data(base64Encoded: existingKey)!
        }
        
        var keyData = Data(count: 32)
        _ = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        
        let keyBase64 = keyData.base64EncodedString()
        try keychainHelper.savePassword(keyBase64, for: masterKeyKey)
        
        return keyData
    }
}
