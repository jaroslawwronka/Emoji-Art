//
//  PaletteList.swift
//  Emoji Art
//
//  Created by boss on 11/03/2024.
//

import SwiftUI

struct EditablePaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    @State private var showCursorPalette = false
    
    var body: some View {
        NavigationStack {
            
            List {
                ForEach(store.palettes) { palette in
                    NavigationLink(value: palette) {
                        VStack(alignment: .leading) {
                            
                            
                            Text(palette.name)
                            Text(palette.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    withAnimation {
                        store.palettes.remove(atOffsets: indexSet)
                    }
                }
                .onMove { indexSet, newOffset in
                    store.palettes.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                if let index = store.palettes.firstIndex(where: { $0.id == palette.id}) {
                    PaletteEditor(palette: $store.palettes[index])
                }
            }
            .navigationDestination(isPresented: $showCursorPalette) {
                PaletteEditor(palette: $store.palettes[store.cursorIndex])
            }
            .navigationTitle("\(store.name) Palettees")
            .toolbar {
                Button {
                    store.insert(name: "", emojis: "")
                    showCursorPalette = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
}

struct PaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        NavigationStack {
            List(store.palettes) { palette in
                NavigationLink(value: palette) {
                    Text(palette.name)
                }
            }
            .navigationDestination(for: Palette.self) { palette in
                PaletteView(palette: palette)
            }
            .navigationTitle("\(store.name) Palettees")
        }
    }
}

struct PaletteView: View {
    let palette: Palette
    
    var body: some View {
        VStack {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    NavigationLink(value: emoji) {
                        Text(emoji)
                    }
                }
            }
            .navigationDestination(for: String.self) { emoji in
                Text(emoji).font(.system(size:300))
            }
            Spacer()
        }
        .padding()
        .font(.largeTitle)
        .navigationTitle(palette.name)
    }
}

    struct PaletteList_Preview: PreviewProvider {
        static var previews: some View {
            PaletteList()
        }
    }
