//
//  ContentView.swift
//  iOSGraphQLExample
//
//  Created by Kotaro Fukuo on 2022/12/02.
//

import SwiftUI

struct User: Decodable {
    let repositories: Repositories
}

struct Repositories: Decodable {
    let nodes: [Repository]
}

struct Repository: Decodable, Identifiable {
    var id: String { url }
    
    let createdAt: String
    let description: String?
    let name: String
    let url: String
}

struct RepositoriesQuery: Query {
    struct Response: Decodable {
        var user: User
    }
    
    var body =
"""
query {
    user(login: "haptaro") {
      repositories(last: 20) {
        nodes {
          name
          description
          createdAt
          url
        }
      }
    }
  }
"""
}

struct ContentView: View {
    @State private var repositories = [Repository]()
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(repositories) { repository in
                        NavigationLink(destination: {
                            RepositoryDetail(
                                name: repository.name,
                                description: repository.description,
                                url: repository.url,
                                createdAt: repository.createdAt
                            )
                        }, label: {
                            RepositoryRow(name: repository.name)
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
                        repositories = data.user.repositories.nodes
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
