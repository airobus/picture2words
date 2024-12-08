import Foundation
import SwiftKeychainWrapper

enum APIKeyManager {
    private static let apiKeyKey = "11"
    
    static func saveAPIKey(_ key: String) {
        KeychainWrapper.standard.set(key, forKey: apiKeyKey)
    }
    
    static func retrieveAPIKey() -> String? {
        return KeychainWrapper.standard.string(forKey: apiKeyKey)
    }
    
    static func deleteAPIKey() {
        KeychainWrapper.standard.removeObject(forKey: apiKeyKey)
    }
    
    // 验证 API Key 有效性的方法
    static func validateAPIKey(_ key: String, completion: @escaping (Bool) -> Void) {
        // 实现 API Key 验证逻辑
        completion(true)
    }
}

// 需要安装 SwiftKeychainWrapper 库 