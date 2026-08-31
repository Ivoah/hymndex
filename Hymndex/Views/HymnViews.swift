//
//  HymnRow.swift
//  trinity
//
//  Created by Noah Rosamilia on 4/30/21.
//

import Foundation
import AVFoundation
import SwiftUI

struct HymnLink: View {
  let hymn: Hymn
  @Binding var tags: [Tag]
  
  var body: some View {
    NavigationLink(value: hymn) {
      VStack(alignment: .leading) {
        Text(hymn.title)
        HStack {
          Text(String(hymn.num))
            .font(.subheadline)
            .foregroundStyle(.secondary)
          ForEach(tags) { tag in
            if tag.hymns.contains(hymn) {
              Circle()
                .foregroundStyle(tag.color.color)
                .frame(width: 10)
            }
          }
          Spacer()
          Text(String(hymn.tune ?? ""))
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
      }
    }
  }
}

struct HymnList: View {
  let hymns: [Hymn]
  @Binding var tags: [Tag]
  @Binding var history: [Event: [Hymn]]
  @Binding var playing: Bool
  @Binding var selectedTab: String
  
  @Binding var selectedHymn: Hymn?
  
  @Environment(\.dismissSearch) private var dismissSearch
  
  private var sections: [(String, [Hymn])] {
    var sections = [(String, [Hymn])]()

    for hymn in hymns {
      let sec = "\(hymn.section): \(hymn.subsection ?? "")"
      if sections.count == 0 || sections.last?.0 != sec {
        sections.append((sec, [Hymn]()))
      }
      sections[sections.count - 1].1.append(hymn)
    }

    return sections
  }
  
  var body: some View {
    List(selection: $selectedHymn) {
      ForEach(sections, id: \.0) { section in
        Section(header: Text(section.0)) {
          ForEach(section.1, id: \.num) { hymn in
            HymnLink(hymn: hymn, tags: $tags)
          }
        }
      }
    }
    .listStyle(.plain)
  }
}

struct HymnView: View {
  let hymn: Hymn
  @Binding var tags: [Tag]
  @Binding var history: [Event: [Hymn]]
  @Binding var playing: Bool
  @Binding var selectedTab: String
  
  @Binding var query: String
  @Binding var selectedHymn: Hymn?
  
  @State private var newDate = Date()
  @State var newLocation: String
  
  var body: some View {
    List {
      Text(hymn.title)
#if os(iOS)
      .onTapGesture {
        UIPasteboard.general.string = hymn.title
      }
#else
      .textSelection(.enabled)
#endif
      if let tune = hymn.tune {
        Section(header: Text("Tune")) {
          Button(action: {
            query = tune
            selectedHymn = nil
          }) {
            HStack {
              Text(tune)
              Spacer()
            }
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
      }
      Section(header: Text("Tags")) {
        ForEach(tags) { tag in
          Button(action: {
            if let i = tags.firstIndex(of: tag) {
              tags[i].hymns = tag.hymns.symmetricDifference([hymn])
              DispatchQueue.main.async {
                saveTags(tags: tags)
              }
            }
          }) {
            HStack {
              Circle()
                .foregroundStyle(tag.color.color)
                .frame(width: 20)
              Text(tag.name)
              Spacer()
              Text(String(tag.hymns.count))
                .foregroundStyle(.secondary)
              Image(systemName: "checkmark")
                .foregroundStyle(.blue)
                .opacity(tag.hymns.contains(hymn) ? 1 : 0)
            }
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
      }
      Section(header: Text("History")) {
        HStack {
          VStack(alignment: .leading) {
            DatePicker("Date", selection: $newDate, displayedComponents: [.date])
            TextField("Location", text: $newLocation)
          }
          .labelsHidden()
          Button(action: {
            if newLocation != "" {
              let event = history.keys.first(where: {Calendar.current.startOfDay(for: $0.date) == Calendar.current.startOfDay(for: Date.now) && $0.location == newLocation}) ?? Event(date: Date.now, location: newLocation)
              if history[event] != nil {
                history[event]!.append(hymn)
              } else {
                history[event] = [hymn]
              }
              newLocation = ""
              DispatchQueue.main.async {
                saveHistory(history: history)
              }
            }
#if os(iOS)
            resignKeyboard()
#endif
          }) {
            Text("Add to history")
          }
          .buttonStyle(.bordered)
        }
        ForEach(history.keys.sorted().reversed(), id: \.self) { event in
          if history[event]!.contains(hymn) {
            // NavigationLink(destination: HistoryView(tags: $tags, history: $history, playing: $playing, scrollTo: event)) {
            Button(action: {
              selectedTab = "History"
            }) {
              HStack {
                VStack(alignment: .leading) {
                  Text(dateFormatter.string(from: event.date))
                  Text(event.location)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
                Spacer()
              }
              .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
          }
        }
      }
    }
//    .listStyle(.grouped)
    .navigationTitle(String(hymn.num))
#if os(iOS)
    .navigationBarTitleDisplayMode(.large)
    .navigationBarItems(trailing: Button(action: {
      let midi = Bundle.main.url(forResource: String(format: "midi/Th2_%03d", hymn.num), withExtension: "mid")
      let font = Bundle.main.url(forResource: "FreeFont", withExtension: "sf2")
      do {
        player = try AVMIDIPlayer(contentsOf: midi!, soundBankURL: font!)
        player?.play()
        playing = true
        do {
          try AVAudioSession.sharedInstance().setActive(playing)
        } catch {}
      } catch {
        print("Unable to play \(String(describing: midi)): \(error)")
      }
    }) {
      Image(systemName: "play.fill")
    })
#endif
  }
}

//struct Hymn_Previews: PreviewProvider {
//  static let hymn = Hymn(
//    num: "359",
//    section: "THE CHURCH",
//    subsection: "The Communion of Saints",
//    title: "Blest Be the Tie That Binds",
//    author: "",
//    composer: "",
//    tune: "DENNIS",
//    meter: "",
//    reference: ""
//  )
//  static var previews: some View {
//    Group {
//      ContentView().preferredColorScheme(.dark)
//      NavigationView {
//        HymnView(hymn: hymn, tags: .constant(loadTags()), history: .constant(loadHistory()), playing: .constant(false)).preferredColorScheme(.dark)
//
//      }
//      HymnList(hymns: hymnals[0].hymns, tags: .constant(loadTags()), history: .constant(loadHistory()), playing: .constant(false)).preferredColorScheme(.dark)
//    }
//  }
//}
