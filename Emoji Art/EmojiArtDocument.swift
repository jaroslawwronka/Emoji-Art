//
//  EmojiArtDocument.swift
//  Emoji Art
//
//  Created by Boss on 13/02/2024.
//
// ViewModel


import SwiftUI
import UniformTypeIdentifiers
extension UTType {
    static let emojiart = UTType(exportedAs: "pl.luxmed.jaroslawwronka.emojiart")
}

class EmojiArtDocument: /*ObservableObject,*/ ReferenceFileDocument {
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
        
    static var readableContentTypes: [UTType] {
        [.emojiart]
    }
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArt(json: data)
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    typealias Emoji = EmojiArt.Emoji
    @Published private var emojiArt = EmojiArt() {
        didSet {
            //autosave()
            if emojiArt.background != oldValue.background {
                Task {
                    await fetchBackgroundImage()
                }
            }
        }
    }
    
 /*   private let autosaveURL: URL = URL.documentsDirectory.appendingPathComponent("Autosaveed.emojiart")
    
    private func autosave() {
        save(to: autosaveURL)
        print("autosaved to \(autosaveURL)")
    }
    
    private func save(to url : URL) {
        do {
            let data = try emojiArt.json()
            try data.write(to: url)
        } catch let error {
            print("EmojiArtDocument: error while saving \(error.localizedDescription)")
        }
    }
    */
    init() {
       
         /* if let data = try? Data(contentsOf: autosaveURL),
             let autosavedEmojiArt = try? EmojiArt(json: data) {
              emojiArt = autosavedEmojiArt
          }*/
        //emojiArt.addEmoji("🚲", at: .init(x: -200, y: -150), size: 500)
        //emojiArt.addEmoji("🕰️", at: .init(x: 250, y: 100), size: 80)
    }
    var emojis: [Emoji] {
        emojiArt.emojis
    }
    
    var bbox: CGRect {
        var bbox = CGRect.zero
        for emoji in emojiArt.emojis {
            bbox = bbox.union(emoji.bbox)
        }
        if let backgroundSize = background.uiImage?.size {
            bbox = bbox.union(CGRect(center: .zero, size: backgroundSize))
        }
        return bbox
    }
 //   var background: URL? {
 //       emojiArt.background
 //   }
    
    @Published var background: Background = .none
    
    @MainActor
    private func fetchBackgroundImage() async {
        if let url = emojiArt.background {
            background = .fetching(url)
            do {
                let image = try await fetchUIImage(from: url)
                if url == emojiArt.background {
                    background = .found(image)
                }
            } catch {
                background = .failed("Couldn't set background: \(error.localizedDescription)")
            }
        } else {
            background = .none
        }
    }
    
    private func fetchUIImage(from url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let uiImage = UIImage(data: data) {
            return uiImage
        } else {
            throw FetchError.badImageData
        }
    }
    
    enum FetchError: Error {
        case badImageData
    }
    
    enum Background {
        case none
        case fetching(URL)
        case found(UIImage)
        case failed(String)
        
        var uiImage:UIImage? {
            switch self {
            case .found(let uiImage): return uiImage
            default: return nil
            }
        }
        
        var isFetching: Bool {urlBeingFetched != nil }
        
        
        var urlBeingFetched: URL? {
            switch self {
                case .fetching(let url): return url
            default: return nil
            }
        }
        
        var failureReason: String? {
            switch self {
            case .failed(let reason): return reason
            default: return nil
            }
        }
    }
    
    private func undoablyPerform(_ action: String, with undoManager: UndoManager? = nil, doit: () -> Void) {
        let oldEmojiArt = emojiArt
        doit()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(action, with: undoManager) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(action)
    }
    
    func setBackGround(_ url:URL?, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Set background", with: undoManager) {
            emojiArt.background = url
        }
        
    }
    func addEmoji(_ emoji: String, at position: Emoji.Position, size: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: position, size: Int(size))
        }
    }
    
    func move(_ emoji: Emoji, by offset: CGOffset, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Move \(emoji)", with: undoManager) {
            let existingPosition = emojiArt[emoji].position
            emojiArt[emoji].position = Emoji.Position(
                x: existingPosition.x + Int(offset.width),
                y: existingPosition.y - Int(offset.height)
                
            )
        }
    }
    
    func move(emojiWithId id: Emoji.ID, by offset: CGOffset, undoWith undoManager: UndoManager? = nil) {
        if let emoji = emojiArt[id] {
            move(emoji, by: offset, undoWith: undoManager)
        }
    }
    
    func resize(_ emoji: Emoji, by scale: CGFloat, undoWith undoManager: UndoManager? = nil) {
        undoablyPerform("Resize \(emoji)", with: undoManager) {
            emojiArt[emoji].size = Int(CGFloat(emojiArt[emoji].size) * scale)
        }
    }
    func resiz(emojiWithId id: Emoji.ID, by scale: CGFloat, undoManager: UndoManager? = nil) {
        if let emoji = emojiArt[id] {
            resize(emoji, by: scale, undoWith: undoManager)
        }
    }
}

extension EmojiArt.Emoji {
    var font: Font {
        Font.system(size: CGFloat(size))
    }
    var bbox: CGRect {
        CGRect(
            center: position.in(nil),
            size: CGSize(width: CGFloat(size), height: CGFloat(size))
            )
    }
}

extension EmojiArt.Emoji.Position {
    func `in`(_ geometry: GeometryProxy?) -> CGPoint {
        let center = geometry?.frame(in: .local).center ?? .zero
        return CGPoint(x: center.x + CGFloat(x),y: center.y - CGFloat(y))
    }
    
}
