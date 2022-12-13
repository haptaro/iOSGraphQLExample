//
//  RepositoryDetail.swift
//  iOSGraphQLExample
//
//  Created by Kotaro Fukuo on 2022/12/12.
//

import SwiftUI

struct RepositoryDetail: View {
    var name: String
    var body: some View {
        Text(name)
    }
}

struct RepositoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryDetail(name: "title")
    }
}
