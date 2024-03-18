//
//  Emoji_ArtApp.swift
//  Emoji Art
//
//  Created by Boss on 13/02/2024.
//

import SwiftUI

@main
struct Emoji_ArtApp: App {
    //@StateObject var defaultDocument = EmojiArtDocument()
    //@StateObject var paletteStore = PaletteStore(named: "Main")
    //@StateObject var store2 = PaletteStore(named: "Alternate")
   // @StateObject var store3 = PaletteStore(named: "Special")
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            /*    PaletteManager(stores: [paletteStore, store2, store3], selectedStore: paletteStore)
             
             
             //ContentView()
             }*/
            //EmojiArtDocumentView(document: config.document)
            //    .environmentObject(paletteStore)
            EmojiArtDocumentView(document: config.document)
        }
    }
}
