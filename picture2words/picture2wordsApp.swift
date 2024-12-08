//
//  picture2wordsApp.swift
//  picture2words
//
//  Created by 庞梦婷 on 2024/12/8.
//

import SwiftUI

@main
struct picture2wordsApp: App {
    init() {
        NetworkMonitor.shared.startMonitoring()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("首页")
                    }
                
                WordListView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("单词")
                    }
                
                HistoryView()
                    .tabItem {
                        Image(systemName: "clock")
                        Text("历史")
                    }
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person")
                        Text("我的")
                    }
            }
        }
    }
}
