//
//  RepositoryRow.swift
//  iOSGraphQLExample
//
//  Created by Kotaro Fukuo on 2022/12/12.
//

import SwiftUI

struct RepositoryRow: View {
    var name: String
    
    var body: some View {
        Text(name)
    }
}

struct RepositoryRow_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryRow(name: "title")
    }
}
