//
//  ContentView.swift
//  Doxgelxi Grokarman
//
//  Created by Zeph Rowan on 25.03.2026.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var store = QuestStore.shared

    var body: some View {
        RootView()
            .environmentObject(store)
    }
}

#Preview {
    ContentView()
}
