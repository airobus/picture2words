//
//  ContentView.swift
//  picture2words
//
//  Created by 庞梦婷 on 2024/12/8.
//

import SwiftUI
import Vision
import AVFoundation

struct ContentView: View {
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @State private var selectedImage: UIImage?
    @State private var showImagePicker = false
    @State private var recognizedWords: [WordInfo] = []
    @State private var isRecognizing = false
    @State private var errorMessage: String?
    @State private var showImageDetail: Bool? = nil
    
    var body: some View {
        NavigationView {
            VStack {
                if !networkMonitor.isConnected {
                    Text("无网络连接")
                        .foregroundColor(.red)
                }
                
                // 图片展示区域
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 300)
                } else {
                    Text("请选择或拍摄图片")
                        .foregroundColor(.gray)
                }
                
                // 识别按钮
                HStack {
                    Button("相册") {
                        showImagePicker = true
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePicker(image: $selectedImage)
                    }
                    
                    Button("AI识别") {
                        if let image = selectedImage, validateImageSize(image) {
                            recognizeImageWithAI()
                        } else {
                            errorMessage = "图片大小不能超过3MB或未选择图片"
                        }
                    }
                    .disabled(selectedImage == nil || isRecognizing)
                }
                .padding()
                
                // 错误信息
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }
                
                // 识别结果展示
                if isRecognizing {
                    ProgressView("正在识别...")
                } else if !recognizedWords.isEmpty {
                    List {
                        ForEach(recognizedWords) { word in
                            HStack {
                                Text(word.word)
                                Spacer()
                                Button("发音") {
                                    speakWord(word)
                                }
                            }
                        }
                    }
                    
                    if let safeImage = selectedImage {
                        NavigationLink(
                            destination: ImageDetailView(originalImage: safeImage, words: recognizedWords),
                            tag: true,
                            selection: $showImageDetail
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
        }
    }
    
    func recognizeImageWithAI() {
        guard let image = selectedImage else { return }
        
        isRecognizing = true
        errorMessage = nil
        recognizedWords.removeAll()
        
        AIService.shared.extractWordsFromImage(image: image) { result in
            DispatchQueue.main.async {
                isRecognizing = false
                
                switch result {
                case .success(let words):
                    self.recognizedWords = words
                    self.showImageDetail = true
                case .failure(let error):
                    self.errorMessage = "识别失败: \(error.localizedDescription)"
                }
            }
        }
    }
    
    func speakWord(_ word: WordInfo) {
        let utterance = AVSpeechUtterance(string: word.word)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    func validateImageSize(_ image: UIImage?) -> Bool {
        guard let image = image,
              let imageData = image.jpegData(compressionQuality: 1.0) else {
            return false
        }
        let imageSizeInMB = Double(imageData.count) / (1024.0 * 1024.0)
        return imageSizeInMB <= 3.0
    }
}

// 图片选择器
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

#Preview {
    ContentView()
}
