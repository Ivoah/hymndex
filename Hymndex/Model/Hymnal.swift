//
//  ModelData.swift
//  trinity
//
//  Created by Noah Rosamilia on 4/30/21.
//

import Foundation

struct HymnKey: Codable, Hashable {
    let hymnal: String
    let num: String
    
    func hymn() -> Hymn {
        hymnals.first(where: {$0.name == hymnal})!.hymns.first(where: {$0.num == num})!
    }
}

struct HymnDetails: Decodable, Hashable {
    // num,section,subsection,title,author,composer,tune,meter,reference
    let num: String
    let section: String
    let subsection: String?
    let title: String
    let author: String?
    let composer: String?
    let tune: String?
    let meter: String?
    let key: String?
    let reference: String?
}

struct Hymn: Hashable {
    let num: String
    let section: String
    let subsection: String?
    let title: String
    let author: String?
    let composer: String?
    let tune: String?
    let meter: String?
    let key: String?
    let reference: String?
    let hymnal: String
    
    func hymnKey() -> HymnKey {HymnKey(hymnal: hymnal, num: num)}
}

struct Hymnal: Identifiable, Hashable, Equatable, Comparable {
    static func < (lhs: Hymnal, rhs: Hymnal) -> Bool {
        lhs.name < rhs.name
    }
    
    let id = UUID()
    let name: String
    let hymns: [Hymn]
    
    init(name: String, from filename: String) {
        self.name = name
        
        guard let file = Bundle.main.url(forResource: filename, withExtension: "json")
            else {
                fatalError("Couldn't find \(filename) in main bundle.")
        }

        do {
            let hymnDetails = try JSONDecoder().decode([HymnDetails].self, from: Data(contentsOf: file))
            self.hymns = hymnDetails.map {
                Hymn(num: $0.num, section: $0.section, subsection: $0.subsection, title: $0.title, author: $0.author, composer: $0.composer, tune: $0.tune, meter: $0.meter, key: $0.key, reference: $0.reference, hymnal: name)
            }
        } catch {
            fatalError("Couldn't read json: \(error)")
        }

    }
}
