import SwiftUI

struct WordListView: View {
    var body: some View {
        NavigationView {
            List {
                Text("单词列表")
            }
            .navigationTitle("单词")
        }
    }
} 