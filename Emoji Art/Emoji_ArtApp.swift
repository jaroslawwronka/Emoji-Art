//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Boss on 13/02/2024.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    @StateObject var defaultDocument = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document:defaultDocument)
            //ContentView()
        }
    }
}
