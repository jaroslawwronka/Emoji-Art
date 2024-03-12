//
//  PaletteList.swift
//  Emoji Art
//
//  Created by boss on 11/03/2024.
//

import SwiftUI

struct PaletteList: View {
    @EnvironmentObject var store: PaletteStore
    
    var body: some View {
        List {
            ForEach(store.palettes) { palette in
                Text(palette.name)
            }
        }
    }
}

#Preview {
    PaletteList()
}
