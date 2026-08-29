//
//  FilterSheet.swift
//  trinity
//
//  Created by Noah Rosamilia on 4/30/21.
//

import Foundation
import SwiftUI

struct TagsSheet: View {
  @Binding var tags: [Tag]
  @Binding var selection: Set<Tag>
  @Binding var visible: Bool
  
#if os(iOS)
  @State var editMode: EditMode = .inactive
#endif
  
  @State var newTagName: String = ""
  @State var newTagColor: Color = .blue
  
  var body: some View {
    NavigationView {
      List {
        ForEach(tags) { tag in
          let editTagName: Binding<String> = Binding(
            get: {tag.name},
            set: { newName in
              if let i = tags.firstIndex(of: tag) {
                tags[i].name = newName
                saveTags(tags: tags)
              }
            }
          )
          let editTagColor: Binding<Color> = Binding(
            get: {tag.color.color},
            set: { newColor in
              if let i = tags.firstIndex(of: tag) {
                tags[i].color = CodableColor(color: newColor)
                saveTags(tags: tags)
              }
            }
          )
          
          Button(action: {
            selection = selection.symmetricDifference([tag])
          }) {
            HStack {
#if os(iOS)
              if (!editMode.isEditing) {
                Circle()
                  .foregroundStyle(tag.color.color)
                  .frame(width: 20)
                Text(tag.name)
                Spacer()
                Text(String(tag.hymns.count))
                  .foregroundStyle(.secondary)
                Image(systemName: "checkmark")
                  .foregroundStyle(.blue)
                  .opacity(selection.contains(tag) ? 1 : 0)
              } else {
                ColorPicker("Tag color", selection: editTagColor, supportsOpacity: false).labelsHidden()
                TextField("Tag name", text: editTagName)
              }
#else
              ColorPicker("Tag color", selection: editTagColor, supportsOpacity: false).labelsHidden()
              TextField("Tag name", text: editTagName)
#endif
            }
            .contentShape(Rectangle())
          }
          .buttonStyle(.plain)
        }
        .onDelete(perform: {
          $0.forEach{selection.remove(tags[$0])}
          tags.remove(atOffsets: $0)
          saveTags(tags: tags)
        })
        .onMove(perform: {
          tags.move(fromOffsets: $0, toOffset: $1)
          saveTags(tags: tags)
        })
      }
      .navigationTitle("Tags")
#if os(iOS)
      .navigationBarTitleDisplayMode(.inline)
      .navigationBarItems(
        leading: HStack {
          EditButton()
          if (editMode.isEditing) {
            Button(action: {
              withAnimation {
                tags.append(Tag(name: "New tag", color: CodableColor(color: .blue), hymns: []))
              }
              saveTags(tags: tags)
            }) {
              Image(systemName: "plus")
            }
          }
        },
        trailing: Button("Close") {
          visible = false
        }
      )
      .environment(\.editMode, $editMode)
#endif
    }
  }
}

struct TagsSheet_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      TagsSheet(tags: .constant([
        Tag(name: "tag 1", color: CodableColor(color: Color.yellow), hymns: [
          HymnKey(hymnalId: "trinity", num: "359").hymn(),
          HymnKey(hymnalId: "trinity", num: "559").hymn(),
          HymnKey(hymnalId: "trinity", num: "297").hymn()
        ]),
        Tag(name: "tag 2", color: CodableColor(color: Color.red), hymns: [
          HymnKey(hymnalId: "trinity", num: "1").hymn(),
          HymnKey(hymnalId: "trinity", num: "4").hymn()
        ])
      ]), selection: .constant([]), visible: .constant(true)).preferredColorScheme(.dark)
    }
  }
}
