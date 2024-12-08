import SwiftUI

struct ImageDetailView: View {
    let originalImage: UIImage
    let words: [WordInfo]
    
    var body: some View {
        ScrollView {
            VStack {
                // 原始图片
                Image(uiImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 300)
                
                // 单词列表
                ForEach(words) { word in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(word.word)
                                .font(.headline)
                            Text(word.phonetic)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Text(word.chineseMeaning)
                            .font(.body)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
            }
        }
        .navigationTitle("图片详情")
    }
} 