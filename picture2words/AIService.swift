//
//  ContentView.swift
//  picture2words
//
//  Created by 庞梦婷 on 2024/12/8.
//

import Foundation
import UIKit
import os.log

class AIService {
    static let shared = AIService()
    
    private var apiKey: String {
        // 从 Keychain 获取，如果没有则使用默认值（实际生产中不推荐）
        return APIKeyManager.retrieveAPIKey() ?? "11"
    }
    
    private let baseURL = "https://models.inference.ai.azure.com/chat/completions"
    
    // 创建日志对象
    private let logger = Logger(subsystem: "com.airobus.picture2words", category: "AIService")
    
    func extractWordsFromImage(image: UIImage, completion: @escaping (Result<[WordInfo], Error>) -> Void) {
        // 记录请求开始日志
        logger.info("开始图像识别请求")
        
        // 网络请求错误处理
        guard NetworkReachability.isConnectedToNetwork() else {
            logger.error("无网络连接")
            completion(.failure(NetworkError.noInternetConnection))
            return
        }
        
        // 压缩和调整图片大小
        guard let resizedImage = resizeImage(image, maxSize: 200),
              let imageData = resizedImage.jpegData(compressionQuality: 0.2) else {
            logger.error("图片处理失败")
            completion(.failure(NSError(domain: "ImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "无法处理图片"])))
            return
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // 记录图片大小信息
        logger.info("原始图片大小: \(image.size.width)x\(image.size.height), 压缩后大小: \(imageData.count) 字节")
        logger.info("Base64编码长度: \(base64Image.count) 字符")
        
        // 构建请求
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "messages": [
                [
                    "role": "system",
                    "content": "请提供图片中所有重要物体的英文单词。每个单词需要返回：单词、音标、中文翻译，格式如：word|/phonetic/|中文翻译。"
                ],
                [
                    "role": "user",
                    "content": base64Image
                ]
            ],
            "temperature": 0.5,
            "max_tokens": 1000,
            "model": "gpt-4o"
        ]
        
        // 详细的请求日志
        logger.info("""
            完整请求详情:
            URL: \(self.baseURL)
            方法: POST
            Headers:
            - Content-Type: application/json
            - Authorization: Bearer \(String(repeating: "*", count: self.apiKey.count))
            """)
        
        // 记录请求详情
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
            if let requestString = String(data: jsonData, encoding: .utf8) {
                logger.debug("请求体详情:\n\(requestString)")
            }
            request.httpBody = jsonData
        } catch {
            logger.error("请求体序列化失败: \(error.localizedDescription)")
            completion(.failure(error))
            return
        }
        
        // 记录请求大小
        if let jsonData = try? JSONSerialization.data(withJSONObject: body),
           let requestString = String(data: jsonData, encoding: .utf8) {
            logger.info("请求体大小: \(requestString.count) 字符")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            // 记录原始响应
            if let error = error {
                self?.logger.error("网络请求错误: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                self?.logger.error("无响应数据")
                completion(.failure(NSError(domain: "NetworkError", code: -2, userInfo: [NSLocalizedDescriptionKey: "无数据返回"])))
                return
            }
            
            // 记录原始响应字符串，方便调试
            if let responseString = String(data: data, encoding: .utf8) {
                self?.logger.debug("原始响应: \(responseString)")
            }
            
            do {
                // 尝试解析 JSON
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    self?.logger.error("JSON解析失败")
                    completion(.failure(NSError(domain: "ParseError", code: -3, userInfo: [NSLocalizedDescriptionKey: "无法解析JSON"])))
                    return
                }
                
                // 详细的 JSON 解析日志
                self?.logger.debug("解析后的 JSON: \(json)")
                
                // 尝试取单词
                guard 
                    let choices = json["choices"] as? [[String: Any]],
                    let firstChoice = choices.first,
                    let message = firstChoice["message"] as? [String: Any],
                    let content = message["content"] as? String 
                else {
                    self?.logger.error("无法提取单词内容")
                    completion(.failure(NSError(domain: "ParseError", code: -4, userInfo: [NSLocalizedDescriptionKey: "解析响应失败"])))
                    return
                }
                
                // 解析返回的单词
                let words = content.components(separatedBy: "\n")
                    .map { line -> WordInfo? in
                        let components = line.components(separatedBy: "|")
                        guard components.count == 3 else { return nil }
                        return WordInfo(
                            word: components[0].trimmingCharacters(in: .whitespacesAndNewlines),
                            phonetic: components[1].trimmingCharacters(in: .whitespacesAndNewlines),
                            chineseMeaning: components[2].trimmingCharacters(in: .whitespacesAndNewlines)
                        )
                    }
                    .compactMap { $0 }
                
                self?.logger.info("识别成功，单词: \(words)")
                completion(.success(words))
                
            } catch {
                self?.logger.error("解析异常: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }.resume()
    }

    // 辅助方法：调整图片大小
    func resizeImage(_ image: UIImage, maxSize: CGFloat) -> UIImage? {
        let aspectWidth = maxSize / image.size.width
        let aspectHeight = maxSize / image.size.height
        let aspectRatio = min(aspectWidth, aspectHeight)
        
        let newWidth = image.size.width * aspectRatio
        let newHeight = image.size.height * aspectRatio
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: newWidth, height: newHeight))
        return renderer.image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        }
    }
}

// 网络连接检查
enum NetworkReachability {
    static func isConnectedToNetwork() -> Bool {
        return NetworkMonitor.shared.isConnected
    }
}

// 自定义网络错误
enum NetworkError: Error {
    case noInternetConnection
    case serverError
    
    var localizedDescription: String {
        switch self {
        case .noInternetConnection:
            return "无网络连接，请检查您的网络设置"
        case .serverError:
            return "服务器错误，请稍后重试"
        }
    }
} 