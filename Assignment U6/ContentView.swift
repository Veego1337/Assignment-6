import SwiftUI

struct ContentView: View {
    @StateObject private var store = TheMetStore()
    @State private var query = "rhino"
    @State private var showQueryField = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("You searched for '\(query)'")
                    .padding(5)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                
                List(store.objects, id: \.objectID) { object in
                    // Tapping the NavigationLink navigates to the detailed ObjectView
                    NavigationLink(destination: ObjectView(object: object)) {
                        Text(object.title)
                    }
                }
                .navigationTitle("The Met")
                .navigationBarItems(trailing: Button("Search") {
                    showQueryField = true
                })
            }
        }
        .onAppear {
            store.fetchObjects(for: query)
        }
        .sheet(isPresented: $showQueryField) {
            VStack(spacing: 20) {
                Text("Search The Met")
                    .font(.headline)
                TextField("Search term", text: $query)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                Button("Search") {
                    store.fetchObjects(for: query)
                    showQueryField = false
                }
            }
        }
    }
}

struct ObjectView: View {
    let object: Object
    
    var body: some View {
        VStack {
            Text(object.title)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            if object.isPublicDomain && !object.primaryImageSmall.isEmpty {
                URLImage(urlString: object.primaryImageSmall)
                    .aspectRatio(contentMode: .fit)
            } else {
                Text("Image not in public domain. URL not valid.")
                    .foregroundColor(.secondary)
            }
            
            Text(object.creditLine)
                .font(.caption)
                .padding()
        }
    }
}
