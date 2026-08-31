//
//  History.swift
//  trinity
//
//  Created by Noah Rosamilia on 5/11/21.
//

import Foundation

struct Event: Codable, Hashable, Comparable {
  let date: Date
  let location: String
  
  var description: String {
    "\(dateFormatter.string(from: date)) - \(location)"
  }

  static func < (lhs: Event, rhs: Event) -> Bool {
    if lhs.date != rhs.date {
      return lhs.date < rhs.date
    } else {
      return lhs.location < rhs.location
    }
  }
}

struct HistoryItem: Codable {
  let event: Event
  let hymns: [HymnKey]
}

func loadHistory() -> [Event: [Hymn]] {
  do {
    let historyFile = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("history.json"))!
    let data = try Data(contentsOf: historyFile)
    let decoded = try JSONDecoder().decode([HistoryItem].self, from: data)
    return Dictionary(uniqueKeysWithValues: decoded.map {($0.event, $0.hymns.map {$0.hymn()})})
  } catch {
    print("Error reading/parsing json: \(error)")
  }

  return [:]
}

func saveHistory(history: [Event: [Hymn]]) {
  do {
    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted
    let jsonData = try encoder.encode(history.map {HistoryItem(event: $0.key, hymns: $0.value.map {$0.hymnKey()})})
    let historyFile = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("history.json"))!
    try jsonData.write(to: historyFile)
  } catch {
    print("Could not save history")
  }
}
