//
//  SearchBar.swift
//  Chats
//
//  Created by Игорь Михайлов on 12.12.2023.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    
    @FocusState private var isFocused
    
    var body: some View {
        HStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search…", text: $searchText)
                    .focused($isFocused)
            }
            .padding(8)
            .background(Color(.systemGray5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            if isFocused {
                Button("Cancel") {
                    isFocused = false
                    searchText = ""
                }
                .tint(.primary)
                .padding(.leading)
            }
        }
        .animation(.default, value: isFocused)
    }
}

#Preview {
    SearchBar(searchText: .constant(""))
}
