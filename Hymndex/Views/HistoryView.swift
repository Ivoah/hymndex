//
//  History.swift
//  trinity
//
//  Created by Noah Rosamilia on 5/11/21.
//

import Foundation
import SwiftUI

struct HistoryView: View {
  @Binding var tags: [Tag]
  @Binding var history: [Event: [Hymn]]
  @Binding var playing: Bool
  
  @Binding var selectedTab: String
  @Binding var selectedHymnal: String?
  @Binding var selectedHymn: Hymn?

  let scrollTo: Event?
  
  var body: some View {
    ScrollViewReader { proxy in
      List {
        ForEach(history.keys.sorted().reversed(), id: \.self) { event in
          Section(header: Text(event.description)) {
            ForEach(history[event]!, id: \.self) { hymn in
              Button(action: {
                selectedTab = "Hymnals"
                selectedHymnal = hymn.hymnalId
                selectedHymn = hymn
              }) {
                HymnLink(hymn: hymn, tags: $tags)
              }
              .buttonStyle(.plain)
            }
            .onMove { indexSet, offset in
              history[event]!.move(fromOffsets: indexSet, toOffset: offset)
              DispatchQueue.main.async {
                saveHistory(history: history)
              }
            }
            .onDelete { indexSet in
              history[event]!.remove(atOffsets: indexSet)
              if history[event]!.isEmpty {
                history[event] = nil
              }
              DispatchQueue.main.async {
                saveHistory(history: history)
              }
            }
          }
        }
      }
      .listStyle(.plain)
      .navigationTitle("History")
#if os(iOS)
      .navigationBarTitleDisplayMode(.large)
#endif
      .toolbar {
#if os(iOS)
        EditButton()
#endif
      }
      .onAppear {
        if let date = scrollTo {
          DispatchQueue.main.async {
            proxy.scrollTo(date, anchor: .top)
          }
        }
      }
    }
  }
}

struct HistoryView_Previews: PreviewProvider {
  @State static private var showingFilter = true

  static var previews: some View {
    Group {
//      HistoryView().preferredColorScheme(.dark)
    }
  }
}
