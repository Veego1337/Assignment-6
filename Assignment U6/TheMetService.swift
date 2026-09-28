import Foundation

struct TheMetService {
    let baseURLString = "https://collectionapi.metmuseum.org/public/collection/v1/"
    let session = URLSession.shared
    
    func getObjectIDs(from queryTerm: String, completion: @escaping (ObjectIDs?) -> Void) {
        var urlComponents = URLComponents(string: baseURLString + "search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "hasImages", value: "true"),
            URLQueryItem(name: "q", value: queryTerm)
        ]
        
        guard let queryURL = urlComponents.url else {
            completion(nil)
            return
        }
        
        session.dataTask(with: URLRequest(url: queryURL)) { data, response, error in
            guard let data = data, error == nil,
                  let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                completion(nil)
                return
            }
            let objectIDs = try? JSONDecoder().decode(ObjectIDs.self, from: data)
            completion(objectIDs)
        }.resume()
    }
    
    func getObject(from objectID: Int, completion: @escaping (Object?) -> Void) {
        guard let objectURL = URL(string: baseURLString + "objects/\(objectID)") else {
            completion(nil)
            return
        }
        
        session.dataTask(with: URLRequest(url: objectURL)) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            let object = try? JSONDecoder().decode(Object.self, from: data)
            completion(object)
        }.resume()
    }
}
