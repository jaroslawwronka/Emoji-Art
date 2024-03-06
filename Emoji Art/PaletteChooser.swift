//
//  PaletteChooser.swift
//  Emoji Art
//
//  Created by Boss on 05/03/2024.
//

import SwiftUI

struct PaletteChooser: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        HStack {
            chooser
            view(for: store.palettes[store.cursorIndex])
        }
        .clipped()
    }
    
    var chooser: some View {
        AnimatedActionButton(systemImage: "paintpalette") {
            store.cursorIndex += 1
        }
        .contextMenu(ContextMenu(menuItems: {
            AnimatedActionButton("New", systemImage: "plus") {
                store.insert(name: "Math", emojis: "➕✖️➗♾️")
            }
            AnimatedActionButton("Delete", systemImage: "minus.circle", role : .destructive) {
                store.palettes.remove(at: store.cursorIndex)
            }
        }))
    }
    
    func view(for palette: Palette) -> some View {
        HStack {
            Text(palette.name)
            ScrollingEmojis(palette.emojis)
        }
        .id(palette.id)
        .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .top)))
    }
}

struct ScrollingEmojis: View {
    let emojis: [String]
    init(_ emojis: String) {
        self.emojis = emojis.uniqued.map { String($0) /*String.init*/}
        
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis, id: \.self) { emoji in
                    Text(emoji)
                        .draggable(emoji)
                }
            }
            
        }
        
    }
    
}

struct PaletteChooser_Preview: PreviewProvider {
    static var previews: some View {
        PaletteChooser()
            .environmentObject(PaletteStore(named: "Preview"))
    }
}
