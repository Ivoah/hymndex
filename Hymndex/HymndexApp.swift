//
//  HymndexApp.swift
//  Hymndex
//
//  Created by Noah Rosamilia on 8/11/26.
//

import SwiftUI
import SwiftData
import AVFoundation

let hymnals = Dictionary(uniqueKeysWithValues: Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "hymnals")?.map {
  let hymnal = Hymnal(from: $0)
  return (hymnal.id, hymnal)
} ?? [])
  
var player: AVMIDIPlayer? = nil

let dateFormatter = { () -> DateFormatter in
  let formatter = DateFormatter()
  formatter.setLocalizedDateFormatFromTemplate("EEEE MMMM d y")
  return formatter
}()

@main
struct HymndexApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      Item.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      MainView()
    }
    .modelContainer(sharedModelContainer)
  }
}
