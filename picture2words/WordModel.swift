import Foundation

struct WordInfo: Identifiable, Hashable {
    let id = UUID()
    let word: String
    let phonetic: String
    let chineseMeaning: String
    
    // 实现 Hashable 协议
    func hash(into hasher: inout Hasher) {
        hasher.combine(word)
        hasher.combine(phonetic)
        hasher.combine(chineseMeaning)
    }
    
    // 实现 Equatable 协议
    static func == (lhs: WordInfo, rhs: WordInfo) -> Bool {
        return lhs.word == rhs.word &&
               lhs.phonetic == rhs.phonetic &&
               lhs.chineseMeaning == rhs.chineseMeaning
    }
} 