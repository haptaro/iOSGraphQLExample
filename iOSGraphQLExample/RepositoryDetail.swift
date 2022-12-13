//
//  RepositoryDetail.swift
//  iOSGraphQLExample
//
//  Created by Kotaro Fukuo on 2022/12/12.
//

import SwiftUI

struct RepositoryDetail: View {
    var name: String
    var description: String?
    var url: String
    var createdAt: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
            if let description {
                Text(description)
            }
            Text(url)
            Text(createdAt)
        }
    }
}

struct RepositoryDetail_Previews: PreviewProvider {
    static var previews: some View {
        RepositoryDetail(
            name: "name",
            description: "description",
            url: "url",
            createdAt: "createdAt"
        )
    }
}
