//
//  PaletteEditor.swift
//  Emoji Art
//
//  Created by Boss on 07/03/2024.
//

import SwiftUI

struct PaletteEditor: View {
    @Binding var palette: Palette
    
    private let emojiFont = Font.system(size:40)
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Name", text: $palette.name)
            }
            Section(header: Text("Emojis")) {
                TextField("Add Emojis Here", text: $emojisToAdd)
                    .font(emojiFont)
                    .onChange(of: emojisToAdd) { emojisToAdd in
                        palette.emojis = (emojisToAdd + palette.emojis)
                        .filter { $0.isEmoji}
                        .uniqued
                    }
                removeEmojis
            }
        }
        .frame(minWidth: 300, minHeight: 350)
    }
    
    var removeEmojis: some View {
        VStack(alignment: .trailing) {
            Text("Tap to remove emojis").font(.caption).foregroundColor(.gray)
            LazyVGrid(columns: [GridItem(.adaptive(minimum:40))]) {
                ForEach(palette.emojis.uniqued.map(String.init), id: \.self) { emoji in
                    Text(emoji)
                    /*.onTapGesture {
                            withAnimation {
                                palette.emojis.remove(at: emoji.startIndex)
                                emojisToAdd.remove(at:emoji.startIndex)
                            }
                        }*/
                }
            }
        }
        .font(emojiFont)
    }
}

struct  PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(palette: <#Binding<Palette>#>)
    }
}
