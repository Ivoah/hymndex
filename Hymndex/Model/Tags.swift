//
//  Tags.swift
//  trinity
//
//  Created by Noah Rosamilia on 6/21/21.
//

import SwiftUI

struct CodableColor : Codable, Hashable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0

#if os(iOS)
    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    var color : Color {
        return Color(uiColor)
    }

    init(uiColor : UIColor) {
        var alpha: CGFloat = 0.0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    
    init(color: Color) {
        self.init(uiColor: UIColor(color))
    }
#else
    var nsColor : NSColor {
        return NSColor(red: red, green: green, blue: blue, alpha: 1)
    }
    
    var color : Color {
        return Color(nsColor)
    }

    init(nsColor : NSColor) {
        var alpha: CGFloat = 0.0
        nsColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
    
    init(color: Color) {
        self.init(nsColor: NSColor(color))
    }
#endif

}

struct Tag: Hashable, Identifiable {
    var id = UUID()
    var name: String
    var color: CodableColor
    var hymns: Set<Hymn>
    
    func codable() -> CodableTag {
        CodableTag(id: id, name: name, color: color, hymns: Set(hymns.map {$0.hymnKey()}))
    }
}

struct CodableTag: Codable {
    let id: UUID
    let name: String
    let color: CodableColor
    let hymns: Set<HymnKey>
    
    func tag() -> Tag {
        Tag(id: id, name: name, color: color, hymns: Set(hymns.map {$0.hymn()}))
    }
}

func loadTags() -> [Tag] {
    do {
        let tagsFile = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("tags.json"))!
        let data = try Data(contentsOf: tagsFile)
        let tags = try JSONDecoder().decode([CodableTag].self, from: data)
        return tags.map {$0.tag()}
    } catch {
        print("Could not load tags (\(error)")
        return []
    }
}

func saveTags(tags: [Tag]) {
    do {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let jsonData = try encoder.encode(tags.map {$0.codable()})
        let tagsFile = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("tags.json"))!
        try jsonData.write(to: tagsFile)
    } catch {
        print("Could not save tags")
    }
}
