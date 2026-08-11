//
//  ContentView.swift
//  trinity
//
//  Created by Noah Rosamilia on 4/27/21.
//

import AVFoundation
import Foundation
import SwiftUI

struct MainView: View {
    @State private var selectedHymnal: Hymnal?
    @State private var selectedHymn: Hymn?
    
    @State var tags: [Tag] = loadTags()
    @State var history: [Event: [Hymn]] = loadHistory()
    @State var playing = player?.isPlaying ?? false
    
    @State private var query: String = ""
    @State private var isEditing = false
    @State private var showingFilter = false

    @State public var selectedTags: Set<Tag> = []

    func filteredHymns(hymnal: Hymnal) -> [Hymn] {
        Int(query) != nil ? hymnal.hymns : hymnal.hymns.filter { hymn in
            selectedTags.isEmpty
            || selectedTags.allSatisfy({$0.hymns.contains(hymn)})
        }.filter { hymn in
            query.isEmpty
            || hymn.title.sanitized().contains(query.sanitized())
            || hymn.tune?.sanitized().contains(query.sanitized()) ?? false
        }
    }
    
    @State private var selectedTab = "Hymnals"

    var body: some View {
        return TabView(selection: $selectedTab) {
            NavigationSplitView {
                List(hymnals, selection: $selectedHymnal) { hymnal in
                    NavigationLink(hymnal.name, value: hymnal)
                }
                .navigationTitle("Hymnals")
            } content: {
                if let hymnal = selectedHymnal {
                    ScrollViewReader { proxy in
                        HymnList(hymns: filteredHymns(hymnal: hymnal), tags: $tags, history: $history, playing: $playing, selectedTab: $selectedTab, selectedHymn: $selectedHymn)
                        .navigationTitle(hymnal.name)
#if os(iOS)
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(
                            trailing: Button(action: {
                                showingFilter.toggle()
                            }) {
                                Text("Tags")
                                ForEach(tags) { tag in
                                    if selectedTags.contains(tag) {
                                        Circle()
                                            .foregroundStyle(tag.color.color)
                                            .frame(width: 10)
                                    }
                                }
                            }
                        )
#endif
#if os(iOS)
                        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always))
#else
                        .searchable(text: $query)
#endif
                        .autocorrectionDisabled()
                        .onSubmit(of: .search) {
                            withAnimation {
                                proxy.scrollTo(query, anchor: .top)
                            }
                        }
#if os(iOS)
                        .resignKeyboardOnDragGesture()
#endif
                        .sheet(isPresented: $showingFilter) {
                            TagsSheet(tags: $tags, selection: $selectedTags, visible: $showingFilter)
                        }
                    }
                } else {
                    Text("Select a hymnal")
                }
            } detail: {
                if let hymn = selectedHymn {
                    HymnView(hymn: hymn, tags: $tags, history: $history, playing: $playing, selectedTab: $selectedTab, query: $query, selectedHymn: $selectedHymn, newLocation: history.keys.sorted().reversed().first(where: {$0.date == Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: Date.now)})?.location ?? "")
                    .navigationTitle(hymn.title)
                }
            }
            .tabItem {
                Label("Hymnals", systemImage: "book")
            }
            .tag("Hymnals")
            
            NavigationStack {
                HistoryView(tags: $tags, history: $history, playing: $playing, selectedTab: $selectedTab, scrollTo: nil)
            }
            .tabItem {
                Label("History", systemImage: "clock")
            }
            .tag("History")
        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .toolbar {
//            ToolbarItem(placement: .bottomBar) {
//                HStack {
//                    if let player = player {
//                        if (playing) {
//                            Button(action: {
//                                player.stop()
//                                playing = false
//                                do {
//                                    try AVAudioSession.sharedInstance().setActive(playing)
//                                } catch {}
//                            }) {
//                                Image(systemName: "pause.fill")
//                            }
//                        } else {
//                            Button(action: {
//                                player.play()
//                                playing = true
//                                do {
//                                    try AVAudioSession.sharedInstance().setActive(playing)
//                                } catch {}
//                            }) {
//                                Image(systemName: "play.fill")
//                            }
//                        }
//                    }
//                    ProgressView(value: progress, total: 1.0).onReceive(timer) { _ in
//                        progress = (player?.currentPosition ?? 0)/(player?.duration ?? 1)
//                        if progress >= 1 {
//                            player = nil
//                            playing = false
//                            do {
//                                try AVAudioSession.sharedInstance().setActive(playing)
//                            } catch {}
//                        }
//                    }
//                }
//            }
//        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MainView().preferredColorScheme(.dark).padding()
        }
    }
}

//struct ExtractedView: View {
//    init(hymnal: Hymnal, tags: Binding<[Tag]>, history: Binding<[Event: [Int]]>, playing: Binding<Bool>, selectedTab: Binding<String>) {
//        // Get the singleton instance.
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
//            // Set the audio session category, mode, and options.
//            try audioSession.setCategory(.playback)
//        } catch {
//            print("Failed to set audio session category.")
//        }
//        
//        self.hymnal = hymnal
//        self._tags = tags
//        self._history = history
//        self._playing = playing
//        self._selectedTab = selectedTab
//    }
//    
//    let hymnal: Hymnal
//    
//    @Binding var tags: [Tag]
//    @Binding var history: [Event: [Int]]
//
//    @State private var query: String = ""
//    @State private var isEditing = false
//    @State private var showingFilter = false
//    
//    @State public var selection: Set<Tag> = []
//    
//    @Binding var playing: Bool
//    @State var progress = 0.0
//    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
//    
//    @Binding var selectedTab: String
//    
//    func filteredHymns() -> [Hymn] {
//        let filtered = hymnal.hymns.filter { hymn in
//            selection.isEmpty
//            || selection.allSatisfy({$0.hymns.contains(hymn.num)})
//        }.filter { hymn in
//            query.isEmpty
//            || hymn.title.sanitized().contains(query.sanitized())
//            || hymn.tune?.sanitized().contains(query.sanitized()) ?? false
//        }
//        return Int(query) != nil ? hymnal.hymns : filtered
//    }
//    
//    var body: some View {
//        NavigationStack {
//            ScrollViewReader { proxy in
//                VStack {
//                    TextField("Search", text: $query) { isEditing in
//                        self.isEditing = isEditing
//                    } onCommit: {
//                        if let num = Int(query) {
//                            withAnimation {
//                                proxy.scrollTo(num, anchor: .top)
//                            }
//                        }
//                    }
//                    .autocorrectionDisabled(true)
//                    .textFieldStyle(RoundedBorderTextFieldStyle())
//                    HymnList(hymns: filteredHymns(), tags: $tags, history: $history, playing: $playing, selectedTab: $selectedTab)
//                }
//                .sheet(isPresented: $showingFilter) {
//                    TagsSheet(tags: $tags, selection: $selection, visible: $showingFilter)
//                }
//                .navigationTitle(hymnal.name)
//                .navigationBarTitleDisplayMode(.inline)
//                .navigationBarItems(
//                    trailing: Button(action: {
//                        showingFilter.toggle()
//                    }) {
//                        Text("Tags")
//                        ForEach(tags) { tag in
//                            if selection.contains(tag) {
//                                Circle()
//                                    .foregroundStyle(tag.color.color)
//                                    .frame(width: 10)
//                            }
//                        }
//                    }
//                )
//            }
//        }
//    }
//}
