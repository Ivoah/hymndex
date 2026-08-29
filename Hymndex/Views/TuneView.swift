//
//  TuneView.swift
//  trinity
//
//  Created by Noah Rosamilia on 11/6/22.
//

import Foundation
import SwiftUI

//struct TuneView: View {
//  let tune: String
//  @Binding var tags: [Tag]
//  @Binding var history: [Event: [Int]]
//  @Binding var playing: Bool
//  @Binding var selectedTab: String
//  
//  var body: some View {
//    List {
//      ForEach(hymnals[0].hymns.filter{$0.tune == tune}, id: \.num) { hymn in
//        HymnRow(hymn: hymn, tags: $tags, history: $history, playing: $playing, selectedTab: $selectedTab)
//      }
//    }
//    .listStyle(.plain)
//    .navigationTitle(tune)
//    .navigationBarTitleDisplayMode(.large)
//  }
//}

//struct TuneView_Previews: PreviewProvider {
//  @State static private var showingFilter = true
//
//  static var previews: some View {
//    Group {
//      NavigationView {
//        TuneView(tune: "DENNIS", tags: .constant(loadTags()), history: .constant(loadHistory()), playing: .constant(false)).preferredColorScheme(.dark)
//      }
//    }
//  }
//}
