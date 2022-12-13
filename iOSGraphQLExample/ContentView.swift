//
//  ContentView.swift
//  iOSGraphQLExample
//
//  Created by Kotaro Fukuo on 2022/12/02.
//

import SwiftUI

struct RepositoriesQuery: Query {
    struct Response: Decodable {
        var user: User
    }
    
    struct User: Decodable {
        let name: String
        let repositories: Repositories
        let url: String
    }
    
    struct Repositories: Decodable {
        let nodes: [Repository]
        let totalCount: Int
    }
    
    struct Repository: Decodable {
        let createdAt: String
        let description: String?
        let name: String
        let updatedAt: String
        let url: String
    }
    
    var body =
"""
query {
    user(login: "haptaro") {
      name
      url
      repositories(last: 20) {
        totalCount
        nodes {
          name
          description
          createdAt
          updatedAt
          url
        }
      }
    }
  }
"""
}

struct ContentView: View {
    @State private var list: [String] = []
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(list, id: \.self) { name in
                        NavigationLink(destination: {
                            RepositoryRow(name: name)
                        }, label: {
                            Text(name)
                        })
                    }
                }
            }
            .onAppear {
                GraphQLManager().request(query: RepositoriesQuery(), params: [:]) { result in
                    switch result {
                    case .failure(_):
                        showErrorAlert = true
                    case .success(let data):
                        list = data.user.repositories.nodes.map { $0.name }
                    }
                }
            }
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"))
            }
            .navigationTitle("GitHub Repository")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
