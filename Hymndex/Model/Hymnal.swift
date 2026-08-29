//
//  ModelData.swift
//  trinity
//
//  Created by Noah Rosamilia on 4/30/21.
//

import Foundation

struct HymnKey: Codable, Hashable {
    let hymnalId: String
    let num: String
    
    func hymn() -> Hymn {
        hymnals[hymnalId]!.hymns.first(where: {$0.num == num})!
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
    let hymnalId: String
    
    func hymnKey() -> HymnKey {HymnKey(hymnalId: hymnalId, num: num)}
}

struct HymnalDetails: Decodable {
    let name: String
    let hymns: [HymnDetails]
}

struct Hymnal: Identifiable, Hashable, Equatable, Comparable {
    static func < (lhs: Hymnal, rhs: Hymnal) -> Bool {
        lhs.name < rhs.name
    }
    
    let id: String
    let name: String
    let hymns: [Hymn]
    
    init(from file: URL) {
        let id = (file.lastPathComponent as NSString).deletingPathExtension
        self.id = id
        
        do {
            let details = try JSONDecoder().decode(HymnalDetails.self, from: Data(contentsOf: file))
            self.name = details.name
            self.hymns = details.hymns.map {
                Hymn(num: $0.num, section: $0.section, subsection: $0.subsection, title: $0.title, author: $0.author, composer: $0.composer, tune: $0.tune, meter: $0.meter, key: $0.key, reference: $0.reference, hymnalId: id)
            }
        } catch {
            fatalError("Couldn't read json: \(error)")
        }

    }
}
